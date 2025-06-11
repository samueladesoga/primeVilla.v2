class UserMailer < ApplicationMailer
  def welcome_email
    @user = params[:user]
    @password = params[:password]
    @url  = "http://example.com/login"
    mail(to: @user.email_address, subject: "Welcome to the SSHall hostel management system")
  end
end
