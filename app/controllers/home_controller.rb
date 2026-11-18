class HomeController < ApplicationController
  def index
    if Current.user.admin?
      active_tenancies = Tenancy.active.includes(:user, :room).order(:end_date).to_a
      @overdue_tenancies = active_tenancies.select(&:expired?)
      @expiring_tenancies = active_tenancies.select(&:expires_within_a_month?)
      @vacant_rooms = Room.vacant.order(:name)
      @room_count = Room.count
      @occupied_count = active_tenancies.size
    else
      @tenancies = Current.user.tenancies.includes(:room).order(end_date: :desc)
      @current_tenancy = @tenancies.find(&:is_active?)
    end
  end
end
