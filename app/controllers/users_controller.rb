class UsersController < ApplicationController
  before_action :require_admin

  def index
    @users = User.all
  end
  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to users_path, notice: 'User was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.js   { render js: "window.location.reload();" }
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email_address, :phone_number, :parent_name, :parent_phone_number)
  end

end