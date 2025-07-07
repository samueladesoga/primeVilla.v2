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

  	def rent_due_soon
	  	user = User.find(params[:user_id])
	    @email = user.email_address
      @full_name = user.name
		  @tenancy_end_date = params[:tenancy_end_date].strftime('%a, %e %b %Y')
	    mail(to: @email, bcc: "samueladesoga@gmail.com", subject: 'SS Hall: Your rent is due soon')
	end

	def rent_over_due
	  	user = User.find(params[:user_id])
	    @email = user.email_address
	    @full_name = user.name
	    @tenancy_end_date = params[:tenancy_end_date].strftime('%a, %e %b %Y')
	    @elapsed_days = params[:elapsed_days]
	    mail(to: @email, bcc: "samueladesoga@gmail.com", subject: 'SS Hall: Your rent is over due')
	end
end
