namespace :rent_expiring do
  desc "Send email to tenants owing"
  task send_emails_to_tenants: :environment do
    today = Date.today
    if today.day == 1
      one_month_later = today >> 1
      active_tenants = User.all.find_all{|u|not u.active_tenancy.nil?}
      active_tenants.each do |at|
        tenancy_end_date = at.active_tenancy.end_date.to_date
        elapsed_days = (today - tenancy_end_date).to_i
        if tenancy_end_date.between?(today, one_month_later)
          TheSendPasswordMailer.rent_due(at.id, tenancy_end_date.strftime('%a, %e %b %Y')).deliver_now
        elsif tenancy_end_date.past?
          TheSendPasswordMailer.rent_over_due(at.id, tenancy_end_date.strftime('%a, %e %b %Y'), elapsed_days).deliver_now
        end
      end
    end
  end
end
