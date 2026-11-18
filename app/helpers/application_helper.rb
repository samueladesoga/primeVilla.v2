module ApplicationHelper
  def tenancy_status_badge(tenancy)
    case tenancy.status
    when :overdue
      tag.span("Overdue by #{pluralize(tenancy.days_overdue, 'day')}", class: "badge-red")
    when :expiring_soon
      tag.span(tenancy.days_remaining.zero? ? "Ends today" : "#{pluralize(tenancy.days_remaining, 'day')} left", class: "badge-amber")
    when :active
      tag.span("Active", class: "badge-green")
    else
      tag.span("Ended", class: "badge-gray")
    end
  end

  def nav_link(label, path)
    active = current_page?(path) || (path != root_path && request.path.start_with?(path))
    link_to label, path, class: [ "block rounded-md px-3 py-2 text-sm font-medium",
                                  active ? "bg-yellow-900 text-white" : "text-orange-100 hover:bg-yellow-700 hover:text-white" ]
  end

  def hostel
    Rails.application.config.x.hostel
  end
end
