class RegistrationsController < ApplicationController
    allow_unauthenticated_access only: %i[new create]
    before_action :resume_session, only: %i[new create]
  
    def new
      @user = User.new
    end

    def create
      generated_password = SecureRandom.alphanumeric(12)
      @user = User.new(user_params.merge(password: generated_password, password_confirmation: generated_password))
      if @user.save
        UserMailer.with(user: @user, password: generated_password).welcome_email.deliver_later
        redirect_to root_path, notice: "You have created a new Tenant successfully. The password has been sent to their email."
      else
        flash[:alert] = @user.errors.full_messages.join(", ")
        render :new, status: :unprocessable_entity
      end
    end
    
    private
    
    def user_params
        params.expect(user: [:email_address, :first_name, :last_name, :password, :password_confirmation])
    end
  end