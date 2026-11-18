class UserMailer < ApplicationMailer
  helper :application

  def welcome_email
    @user = params[:user]
    @setup_url = edit_password_url(@user.generate_token_for(:account_setup))
    mail(to: @user.email_address, bcc: hostel.admin_email, subject: "Welcome to the SS Hall hostel management system")
  end

  def tenancy_created
    @tenancy = params[:tenancy]
    mail(to: @tenancy.user.email_address, bcc: hostel.admin_email, subject: "SS Hall: Your tenancy has been registered")
  end

  def rent_due_soon
    user = User.find(params[:user_id])
    @full_name = user.name
    @tenancy_end_date = params[:tenancy_end_date].strftime("%a, %e %b %Y")
    mail(to: user.email_address, bcc: hostel.admin_email, subject: "SS Hall: Your rent is due soon")
  end

  def rent_over_due
    user = User.find(params[:user_id])
    @full_name = user.name
    @tenancy_end_date = params[:tenancy_end_date].strftime("%a, %e %b %Y")
    @elapsed_days = params[:elapsed_days]
    mail(to: user.email_address, bcc: hostel.admin_email, subject: "SS Hall: Your rent is overdue")
  end

  private
    def hostel
      Rails.application.config.x.hostel
    end
end
