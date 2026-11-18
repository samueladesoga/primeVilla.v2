class PasswordsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_user_by_token, only: %i[ edit update ]

  def new
  end

  def create
    if user = User.find_by(email_address: params[:email_address])
      PasswordsMailer.reset(user).deliver_later
    end

    redirect_to new_session_path, notice: "Password reset instructions sent (if user with that email address exists)."
  end

  def edit
  end

  def update
    if params[:password].present? && @user.update(params.permit(:password, :password_confirmation))
      @user.sessions.destroy_all
      start_new_session_for @user
      redirect_to root_path, notice: "Your password has been set. Welcome!"
    else
      redirect_to edit_password_path(params[:token]), alert: @user.errors.full_messages.to_sentence.presence || "Please enter a new password."
    end
  end

  private
    def set_user_by_token
      @user = User.find_by_password_token(params[:token])
      redirect_to new_password_path, alert: "That link is invalid or has expired. Request a new one below." unless @user
    end
end
