class SessionsController < ApplicationController
  def create
    user = User.find_by email: params.dig(:session, :email)
    if user&.authenticate(params.dig(:session, :password))
      handle_login user
    else
      flash.now[:danger] = t ".invalid"
      render :new
    end
  end

  def destroy
    log_out
    redirect_to root_url, status: :see_other
  end

  private

  def handle_login user
    if user.activated?
      log_in user
      params[:session][:remember_me] == "1" ? remember(user) : forget(user)
      redirect_back_or user
    else
      flash[:warning] = t ".not_activated"
      redirect_to root_url
    end
  end
end
