namespace :rent_expiring do
  desc "Send email to tenants owing"
  task send_emails_to_tenants: :environment do
    today = Date.today
    active_tenancies = Tenancy.where(is_active: true)
    active_tenancies.each do |tenancy|
        if tenancy.expires_within_a_month?
          UserMailer.with(user_id: tenancy.user.id, tenancy_end_date: tenancy.end_date).rent_due_soon.deliver_later
          puts "Processing tenancy for user: #{tenancy.user.name} in room: #{tenancy.room.name} with end date: #{tenancy.end_date}"
        elsif tenancy.expired?
          elapsed_days = (today - tenancy.end_date.to_date).to_i
          UserMailer.with(user_id: tenancy.user.id, tenancy_end_date: tenancy.end_date, elapsed_days: elapsed_days).rent_over_due.deliver_later
          puts "Processing tenancy for user: #{tenancy.user.name} in room: #{tenancy.room.name} with end date: #{tenancy.end_date}"
        end
      end
  end
end
