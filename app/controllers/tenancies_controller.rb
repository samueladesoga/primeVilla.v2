class TenanciesController < ApplicationController
  before_action :set_tenancy, only: %i[ show edit update destroy ]

  # GET /tenancies or /tenancies.json
  def index
    @tenancies = Tenancy.all
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
          @tenancy.room.update!(is_empty: false)
        end
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
        if @tenancy.save
          @tenancy.room.update!(is_empty: false) if @tenancy.room.present?
          format.html { redirect_to @tenancy, notice: "Tenancy was successfully updated." }
        else
          raise ActiveRecord::Rollback
          format.html { render :edit, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /tenancies/1 or /tenancies/1.json
  
  def destroy
    @tenancy.room.update!(is_empty: true)
    respond_to do |format|
      format.html { redirect_to tenancies_path, status: :see_other, notice: "#{@tenancy.room.name} is now empty" }
      format.turbo_stream
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tenancy
      @tenancy = Tenancy.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def tenancy_params
      params.expect(tenancy: [ :user_id, :room_id, :start_date, :end_date, :comments ])
    end
end
