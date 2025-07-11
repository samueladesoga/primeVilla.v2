class HomeController < ApplicationController
  def index
    active_tenancies = Tenancy.where(is_active: true)
    @active_tenancies_with_expired_rents = active_tenancies.select { |tenancy| tenancy.expired? }
    @occupied_rooms = active_tenancies.map(&:room)
    @vacant_rooms = Room.where.not(id: @occupied_rooms.map(&:id))
  end
end
