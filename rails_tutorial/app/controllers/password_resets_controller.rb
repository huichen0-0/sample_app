class PasswordResetsController < ApplicationController
  before_action :find_user, :valid_user, :check_expiration,
                only: %i(edit update)
  def new; end

  def create
    @user = User.find_by email: params.dig(:password_reset, :email)&.downcase
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = t ".success"
      redirect_to root_url
    else
      flash.now[:danger] = t ".fail"
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if user_params[:password].empty?
      @user.errors.add :password, t(".error")
      render :edit, status: :unprocessable_entity
    elsif @user.update(user_params)
      log_in @user
      @user.update_column :reset_digest, nil
      flash[:success] = t ".success"
      redirect_to @user
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def find_user
    @user = User.find_by email: params[:email]
    return if @user

    flash[:warning] = t "warning_not_found"
    redirect_to root_path
  end

  def valid_user
    return if @user.activated? && @user.authenticated?(:reset, params[:id])

    flash[:danger] = t "warning_not_valid"
    redirect_to root_url
  end

  def check_expiration
    return unless @user.password_reset_expired?

    flash[:danger] = t ".expired"
    redirect_to new_password_reset_url
  end
end
