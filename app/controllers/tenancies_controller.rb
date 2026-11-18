class TenanciesController < ApplicationController
  before_action :require_admin
  before_action :set_tenancy, only: %i[ show edit update destroy renew ]

  def index
    @rooms = Room.includes(active_tenancy: :user).order(:name)

    respond_to do |format|
      format.html
      format.pdf do
        send_data TenancyReportPdf.new(@rooms).render,
          filename: "tenancy-report-#{Date.current.iso8601}.pdf", type: "application/pdf", disposition: "attachment"
      end
    end
  end

  def show
  end

  def new
    @tenancy = Tenancy.new(user_id: params[:user_id], room_id: params[:room_id])
  end

  # Pre-fills a new tenancy that follows on from an existing one.
  def renew
    @previous_tenancy = @tenancy
    @tenancy = Tenancy.new(@previous_tenancy.renewal_attributes)
    render :new
  end

  def edit
  end

  def create
    @tenancy = Tenancy.new(tenancy_params.merge(is_active: true))
    @previous_tenancy = Tenancy.find_by(id: params[:previous_tenancy_id]) if params[:previous_tenancy_id].present?

    saved = Tenancy.transaction do
      @previous_tenancy&.update!(is_active: false)
      @tenancy.save || raise(ActiveRecord::Rollback)
    end

    if saved
      UserMailer.with(tenancy: @tenancy).tenancy_created.deliver_later
      notice = @previous_tenancy ? "Tenancy renewed until #{helpers.l(@tenancy.end_date)}." : "Tenancy was created."
      redirect_to @tenancy, notice: notice
    else
      @previous_tenancy&.reload
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @tenancy.update(tenancy_params)
      redirect_to @tenancy, notice: "Tenancy was updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # Ends the tenancy (keeps it as history) rather than deleting it.
  def destroy
    @tenancy.update!(is_active: false)
    @room = @tenancy.room
    message = "#{@room.name} is now empty."

    if params[:return_to] == "show"
      redirect_to @tenancy, status: :see_other, notice: message
    else
      respond_to do |format|
        format.turbo_stream { flash.now[:notice] = message }
        format.html { redirect_to tenancies_path, status: :see_other, notice: message }
      end
    end
  end

  private
    def set_tenancy
      @tenancy = Tenancy.find(params.expect(:id))
    end

    def tenancy_params
      params.expect(tenancy: [ :user_id, :room_id, :start_date, :end_date, :comments ])
    end
end
