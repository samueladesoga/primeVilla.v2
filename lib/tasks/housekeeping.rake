namespace :rent_expiring do
  desc "Send email to tenants owing"
  task send_emails_to_tenants: :environment do
    today = Date.today
    occupied_rooms = Room.all.find_all{|room|!room.is_empty?}
    latest_tenancies = occupied_rooms.map do |room|
      room.tenancies.order(end_date: :desc).first
    end.compact
   latest_tenancies.each do |tenancy|
      if tenancy.expires_within_a_month?
        UserMailer.with(tenancy.user.id, tenancy.end_date.strftime('%a, %e %b %Y')).rent_due.deliver_later
      elsif tenancy.expired?
        elapsed_days = (today - tenancy.end_date.to_date).to_i
        UserMailer.with(tenancy.user.id, tenancy.end_date.strftime('%a, %e %b %Y'), elapsed_days).rent_over_due.deliver_later
      end
    end
  end
end
