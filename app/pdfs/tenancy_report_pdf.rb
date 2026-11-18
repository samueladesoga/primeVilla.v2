require "prawn"
require "prawn/table"

# A4 landscape report of every room and its current tenancy, for download from
# the tenancies page.
class TenancyReportPdf
  include Prawn::View
  include ActionView::Helpers::TextHelper

  # Drop NotoSans-Regular.ttf and NotoSans-Bold.ttf (or any Unicode TTF pair with
  # these names) here to render ₦ and Yoruba letters such as ẹ, ọ, ṣ exactly.
  FONT_DIR = Rails.root.join("app/assets/fonts")
  UNICODE_FONT = { normal: FONT_DIR.join("NotoSans-Regular.ttf"), bold: FONT_DIR.join("NotoSans-Bold.ttf") }

  BRAND = "92400E"   # yellow-800, matches the navbar
  ACCENT = "F97316"  # orange-500, matches the site title
  TEXT = "1F2937"
  MUTED = "6B7280"
  RULE = "E5E7EB"
  STRIPE = "F9FAFB"
  STATUS_COLORS = {
    overdue: { background: "FEE2E2", text: "991B1B" },
    expiring_soon: { background: "FEF3C7", text: "92400E" },
    active: { background: "DCFCE7", text: "166534" },
    vacant: { background: "F3F4F6", text: "4B5563" }
  }

  def initialize(rooms, generated_on: Date.current, hostel: Rails.application.config.x.hostel)
    @rooms = rooms
    @generated_on = generated_on
    @hostel = hostel
    @tenancies = rooms.filter_map(&:active_tenancy)
  end

  def document
    @document ||= Prawn::Document.new(page_size: "A4", page_layout: :landscape, margin: [ 36, 36, 48, 36 ],
                                      info: { Title: "Tenancy report #{date(@generated_on)}", Creator: @hostel.name })
  end

  def render
    setup_fonts
    header
    summary
    tenancy_table
    footer
    document.render
  end

  private
    def setup_fonts
      @unicode = UNICODE_FONT.values.all?(&:exist?)
      if @unicode
        font_families.update("Report" => UNICODE_FONT.transform_values(&:to_s))
        font "Report"
      else
        Prawn::Fonts::AFM.hide_m17n_warning = true
        font "Helvetica"
      end
      default_leading 1
    end

    def header
      fill_color ACCENT
      text safe(@hostel.name), size: 10, style: :bold
      fill_color TEXT
      text "Tenancy report", size: 22, style: :bold
      fill_color MUTED
      text "Generated #{date(@generated_on)}", size: 9
      fill_color TEXT
      move_down 14
    end

    def summary
      occupied = @tenancies.size
      boxes = [
        [ "Occupied", "#{occupied} / #{@rooms.size}", TEXT ],
        [ "Vacant", (@rooms.size - occupied).to_s, TEXT ],
        [ "Expiring in 30 days", @tenancies.count { _1.status == :expiring_soon }.to_s, "B45309" ],
        [ "Overdue", @tenancies.count { _1.status == :overdue }.to_s, "B91C1C" ]
      ]
      gap = 12
      box_width = (bounds.width - gap * (boxes.size - 1)) / boxes.size
      top = cursor
      boxes.each_with_index do |(label, value, color), i|
        bounding_box([ i * (box_width + gap), top ], width: box_width, height: 46) do
          stroke_color RULE
          fill_color "FFFFFF"
          fill_and_stroke_rounded_rectangle [ 0, bounds.top ], bounds.width, bounds.height, 6
          indent(10) do
            move_down 8
            fill_color MUTED
            text label, size: 8
            fill_color color
            text value, size: 16, style: :bold
          end
        end
      end
      fill_color TEXT
      move_down 18
    end

    def tenancy_table
      rows = @rooms.map { |room| row_for(room) }
      data = [ [ "Room", "Tenant", "Tenant phone", "Parent / next of kin", "Next of kin phone", "Start", "End", "Status", "Notes" ] ] + rows.map { _1[:cells] }

      table(data, header: true, width: bounds.width,
            column_widths: { 0 => 52, 1 => 100, 2 => 80, 3 => 100, 4 => 82, 5 => 62, 6 => 62, 7 => 82 },
            cell_style: { size: 8.5, padding: [ 6, 6 ], border_width: 0, text_color: TEXT, valign: :center }) do |t|
        t.row(0).font_style = :bold
        t.row(0).text_color = "FFFFFF"
        t.row(0).background_color = BRAND
        t.row(0).size = 8

        rows.each_with_index do |row, i|
          r = i + 1
          t.row(r).background_color = STRIPE if i.odd?
          t.row(r).borders = [ :bottom ]
          t.row(r).border_width = 0.5
          t.row(r).border_color = RULE
          t.row(r).column(0).font_style = :bold

          colors = STATUS_COLORS[row[:status]]
          if colors
            t.cells[r, 7].background_color = colors[:background]
            t.cells[r, 7].text_color = colors[:text]
            t.cells[r, 7].font_style = :bold
          end
          t.row(r).columns(1..6).text_color = MUTED if row[:status] == :vacant
        end
      end
    end

    def row_for(room)
      tenancy = room.active_tenancy
      return { status: :vacant, cells: [ safe(room.name), "Vacant", "", "", "", "", "", "Vacant", "" ] } unless tenancy

      user = tenancy.user
      {
        status: tenancy.status,
        cells: [
          safe(room.name),
          safe(user.name),
          safe(user.phone_number.presence || "-"),
          safe(user.parent_name.presence || "-"),
          safe(user.parent_phone_number.presence || "-"),
          date(tenancy.start_date),
          date(tenancy.end_date),
          status_label(tenancy),
          safe(tenancy.comments)
        ]
      }
    end

    def status_label(tenancy)
      case tenancy.status
      when :overdue then "Overdue #{pluralize(tenancy.days_overdue, 'day')}"
      when :expiring_soon then tenancy.days_remaining.zero? ? "Ends today" : "#{pluralize(tenancy.days_remaining, 'day')} left"
      else "Active"
      end
    end

    def footer
      repeat(:all) do
        bounding_box([ bounds.left, bounds.bottom - 16 ], width: bounds.width, height: 14) do
          stroke_color RULE
          stroke_horizontal_rule
          move_down 4
          fill_color MUTED
          text "#{safe(@hostel.name)} · Tenancy report · #{date(@generated_on)}", size: 7.5
        end
      end
      number_pages "Page <page> of <total>", at: [ bounds.right - 100, bounds.bottom - 20 ], width: 100, align: :right, size: 7.5, color: MUTED
    end

    def date(value)
      I18n.l(value)
    end

    # Built-in PDF fonts only cover Windows-1252, so without a Unicode font
    # replace what they can't draw (₦ -> NGN, ẹ -> e) instead of failing.
    def safe(value)
      text = value.to_s
      return text if @unicode

      text.gsub("₦", "NGN ").each_char.map do |char|
        char.encode("Windows-1252")
        char
      rescue Encoding::UndefinedConversionError
        char.unicode_normalize(:nfkd).encode("Windows-1252", undef: :replace, replace: "").encode("UTF-8")
      end.join
    end
end
