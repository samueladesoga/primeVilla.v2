# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def welcome_email
    UserMailer.with(user: User.tenants.first).welcome_email
  end

  def tenancy_created
    UserMailer.with(tenancy: Tenancy.first).tenancy_created
  end

  def rent_due_soon
    tenancy = Tenancy.first
    UserMailer.with(user_id: tenancy.user_id, tenancy_end_date: tenancy.end_date).rent_due_soon
  end

  def rent_over_due
    tenancy = Tenancy.first
    UserMailer.with(user_id: tenancy.user_id, tenancy_end_date: tenancy.end_date, elapsed_days: 5).rent_over_due
  end
end
