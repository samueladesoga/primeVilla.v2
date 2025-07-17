class TenanciesController < ApplicationController
  before_action :require_admin
  before_action :set_tenancy, only: %i[ show edit update destroy ]

  # GET /tenancies or /tenancies.json
  def index
    @rooms = Room.all
  end

  # GET /tenancies/1 or /tenancies/1.json
  def show
  end

  # GET /tenancies/new
  def new
    @tenancy = Tenancy.new
  end

  # GET /tenancies/1/edit
  def edit
  end

  # POST /tenancies or /tenancies.json

  def create
    @tenancy = Tenancy.new(tenancy_params)

    respond_to do |format|
      begin
        ActiveRecord::Base.transaction do
          @tenancy.save!
        end
        UserMailer.with(tenancy: @tenancy).tenancy_created.deliver_later
        format.html { redirect_to @tenancy, notice: "Tenancy was successfully created." }
        format.json { render :show, status: :created, location: @tenancy }
      rescue ActiveRecord::RecordInvalid => e
        format.html do
          flash.now[:alert] = "Error: #{e.record.errors.full_messages.join(', ')}"
          render :new, status: :unprocessable_entity
        end
        format.json { render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tenancies/1 or /tenancies/1.json
  def update
    respond_to do |format|
      ActiveRecord::Base.transaction do
        
        @tenancy.assign_attributes(tenancy_params)
        if @tenancy.save
          @tenancy.update!(is_active: true)
          format.html { redirect_to @tenancy, notice: "Tenancy was successfully updated." }
          format.json { render :show, status: :updated, location: @tenancy }
        else
          raise ActiveRecord::Rollback
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @tenancy.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /tenancies/1 or /tenancies/1.json
  
  def destroy
    @tenancy.update!(is_active: false)
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to tenancies_path, status: :see_other, notice: "#{@tenancy.room.name} is now empty" }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tenancy
      @tenancy = Tenancy.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def tenancy_params
      params.expect(tenancy: [ :user_id, :room_id, :start_date, :end_date, :comments, :is_active ])
    end
end
