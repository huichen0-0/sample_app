class UsersController < ApplicationController
  before_action :logged_in_user, except: %i(show new create)
  before_action :find_user, except: %i(index new create)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: :destroy

  # GET /users or /users.jsons
  def index
    @pagy, @users = pagy User.desc
  end

  # GET /users/1 or /users/1.json
  def show
    @page, @microposts = pagy @user.microposts.desc
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # POST /users or /users.json
  def create
    @user = User.new user_params
    if @user.save
      @user.send_activation_email
      flash[:info] = t ".notification"
      redirect_to root_path, status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @user.update user_params
      flash[:success] = t ".success"
      redirect_to @user
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = t ".success"
    else
      flash[:danger] = t ".fail"
    end
    redirect_to users_path
  end

  def following
    @title = "Following"
    @pagy, @users = pagy @user.following
    render :show_follow
  end

  def followers
    @title = "Followers"
    @pagy, @users = pagy @user.followers
    render :show_follow
  end
  private
  # Use callbacks to share common setup or constraints between actions.
  def find_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:warning] = t "warning_not_found"
    redirect_to root_path
  end

  def correct_user
    return if current_user? @user

    flash[:error] = t "warning_edit"
    redirect_to root_url
  end

  # Only allow a list of trusted parameters through.
  def user_params
    params.require(:user).permit(:name, :email, :password,
                                 :password_confirmation)
  end
end
