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

  	def rent_due_soon(user_id, tenancy_end_date)
	  	user = User.find(user_id)
	    @email = user.email
		  @tenancy_end_date = tenancy_end_date
	    @full_name = user.full_name
	    mail(to: @email, bcc: "samueladesoga@gmail.com", subject: 'SS Hall: Your rent is due soon')
	end

	def rent_over_due(user_id, tenancy_end_date, elapsed_days)
	  	user = User.find(user_id)
	    @email = user.email
	    @full_name = user.full_name
	    @tenancy_end_date = tenancy_end_date
	    @elapsed_days = elapsed_days
	    mail(to: @email, bcc: "samueladesoga@gmail.com", subject: 'SS Hall: Your rent is over due')
	end
end
