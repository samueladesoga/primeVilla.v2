class UserMailer < ApplicationMailer
  def welcome_email
    @user = params[:user]
    @password = params[:password]
    mail(to: @user.email_address, subject: "Welcome to the SSHall hostel management system")
  end

  def tenancy_created
    @tenancy = params[:tenancy]
    mail(to: @tenancy.user.email_address, subject: "Tenancy Created on SS Hall Hostel Management System")
  end
end
