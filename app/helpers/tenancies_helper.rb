module TenanciesHelper
  # Tenants without an active tenancy, plus the tenancy's own tenant so that
  # editing or renewing keeps the current selection.
  def tenant_options_for(tenancy)
    users = User.tenants.without_active_tenancy.to_a
    users << tenancy.user if tenancy.user && users.exclude?(tenancy.user)
    users.sort_by { |user| user.name.downcase }
  end

  # Vacant rooms, plus the tenancy's own room.
  def room_options_for(tenancy)
    rooms = Room.vacant.to_a
    rooms << tenancy.room if tenancy.room && rooms.exclude?(tenancy.room)
    rooms.sort_by { |room| room.name.downcase }
  end
end
