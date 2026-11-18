class UsersController < ApplicationController
  before_action :require_admin
  before_action :set_user, only: %i[ show edit update destroy ]

  def index
    @users = User.tenants.includes(active_tenancy: :room).order(:first_name, :last_name)
    if params[:q].present?
      query = "%#{User.sanitize_sql_like(params[:q].strip)}%"
      @users = @users.where("first_name LIKE :q OR last_name LIKE :q OR email_address LIKE :q OR phone_number LIKE :q", q: query)
    end
  end

  def show
    @tenancies = @user.tenancies.includes(:room).order(end_date: :desc)
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to @user, notice: "#{@user.name} was updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user.destroy
      redirect_to users_path, status: :see_other, notice: "#{@user.name} was deleted."
    else
      redirect_to @user, status: :see_other,
        alert: "#{@user.name} can't be deleted because they have tenancy history."
    end
  end

  private
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.expect(user: [ :first_name, :last_name, :email_address, :phone_number, :parent_name, :parent_phone_number ])
    end
end
