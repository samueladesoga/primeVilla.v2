class RoomsController < ApplicationController
  before_action :require_admin
  before_action :set_room, only: %i[ show edit update destroy ]

  def index
    @rooms = Room.in_room_order(Room.includes(active_tenancy: :user))
  end

  def show
    @tenancies = @room.tenancies.includes(:user).order(end_date: :desc)
  end

  def new
    @room = Room.new
  end

  def edit
  end

  def create
    @room = Room.new(room_params)
    if @room.save
      redirect_to rooms_path, notice: "#{@room.name} was added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @room.update(room_params)
      redirect_to rooms_path, notice: "#{@room.name} was updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @room.destroy
      redirect_to rooms_path, status: :see_other, notice: "#{@room.name} was deleted."
    else
      redirect_to @room, status: :see_other,
        alert: "#{@room.name} can't be deleted because it has tenancy history. Rename it instead if it is no longer used."
    end
  end

  private
    def set_room
      @room = Room.find(params.expect(:id))
    end

    def room_params
      params.expect(room: [ :name ])
    end
end
