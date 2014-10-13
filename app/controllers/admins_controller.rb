class AdminsController < ApplicationController

  rescue_from CanCan::AccessDenied, :with => :handle_access_denied

  def handle_access_denied exception
    if user_signed_in?
      flash[:error] = t('admins.accesss_forbidden')
    end
    redirect_to root_path
  end

  def new_user
    authorize! :manage, User
    @user = User.new
    respond_to do |format|
      format.html { render layout: !request.xhr? }
    end
  end

  def create_user
    @user = User.new(admins_params)
    authorize! :manage, User

    if @user.save
      @user.confirm!
      flash[:success] = t("admins.user.created")
      respond_to do |format|
        format.html { redirect_to manage_users_path }
      end
    else
      puts @user.errors.messages.inspect
      flash[:error] = t('admins.user.error')
      respond_to do |format|
        format.html { redirect_to manage_users_path }
      end
    end
  end

  private

  def admins_params
    unless params[:user].blank?
      params[:user].permit(*admins_allowed_params)
    else
      {}
    end
  end

  def admins_allowed_params
    [ :email, :username, :password, :password_confirmation, :current_password, :institution_id, :_full_name ]
  end

end
