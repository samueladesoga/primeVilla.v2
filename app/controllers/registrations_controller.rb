class RegistrationsController < ApplicationController
  before_action :require_admin

  def new
    @user = User.new
  end

  def create
    # The tenant never sees this password; the welcome email links them to set their own.
    generated_password = SecureRandom.alphanumeric(32)
    @user = User.new(user_params.merge(password: generated_password, password_confirmation: generated_password))
    if @user.save
      UserMailer.with(user: @user).welcome_email.deliver_later
      redirect_to new_tenancy_path(user_id: @user.id),
        notice: "#{@user.name} was created and emailed a link to set their password. Now assign them a room."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def user_params
      params.expect(user: [ :email_address, :first_name, :last_name, :phone_number, :parent_name, :parent_phone_number ])
    end
end
