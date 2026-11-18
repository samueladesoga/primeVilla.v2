# Lets any signed-in user update their own contact details and password.
class ProfilesController < ApplicationController
  def edit
    @user = Current.user
  end

  def update
    @user = Current.user
    attributes = profile_params
    if attributes[:password].blank?
      attributes = attributes.except(:password, :password_confirmation, :password_challenge)
    end

    if @user.update(attributes)
      redirect_to root_path, notice: "Your profile was updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def profile_params
      params.expect(user: [ :first_name, :last_name, :phone_number, :parent_name, :parent_phone_number,
                            :password, :password_confirmation, :password_challenge ])
    end
end
