class HomeController < ApplicationController
  def index
    if Current.user.admin?
      active_tenancies = Tenancy.active.includes(:user, :room).sort_by { |tenancy| tenancy.room.sort_key }
      @overdue_tenancies = active_tenancies.select(&:expired?)
      @expiring_tenancies = active_tenancies.select(&:expires_within_a_month?)
      @vacant_rooms = Room.in_room_order(Room.vacant)
      @room_count = Room.count
      @occupied_count = active_tenancies.map(&:room_id).uniq.size
    else
      @tenancies = Current.user.tenancies.includes(:room).order(end_date: :desc)
      @current_tenancy = @tenancies.find(&:is_active?)
    end
  end
end
