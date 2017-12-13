# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "digest/sha1"

class UsersController < InheritedResources::Base
  include Mconf::ApprovalControllerModule # for approve and disapprove
  include Mconf::DisableControllerModule # for enable, disable
  include Mconf::SelectControllerModule # for select
  include ApplicationHelper

  respond_to :html, except: [:select, :current, :fellows]
  respond_to :json, only: [:select, :current, :fellows]
  respond_to :xml, only: [:current]

  defaults finder: :find_by_slug!
  load_and_authorize_resource :find_by => :username, :except => [:enable, :index, :destroy]
  before_filter :load_and_authorize_with_disabled, :only => [:enable, :destroy]

  # Rescue username not found rendering a 404
  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  # modals
  before_filter :force_modal, only: :new

  layout :determine_layout

  def determine_layout
    case params[:action].to_sym
    when :show
      'no_sidebar'
    when :new
      false
    else
      'application'
    end
  end

  def index
    @space = Space.find_by!(slug: params[:space_id])
    webconf_room!

    authorize! :show, @space

    @users = @space.users.joins(:profile)
      .order("profiles.full_name ASC")
      .paginate(:page => params[:page], :per_page => 10)
    @userCount = @space.users.count
  end

  def show
    @user_spaces = @user.spaces

    # Show activity only in spaces where the current user is a member
    in_spaces = current_user.present? ? current_user.space_ids : []
    @recent_activities = RecentActivity.user_public_activity(@user, in_spaces: in_spaces)
    @recent_activities = @recent_activities.order('updated_at DESC').page(params[:page])

    @profile = @user.profile
    render :show
  end

  def edit
    if current_user == @user # user editing himself
      if @user.shib_token.present?
        shib = Mconf::Shibboleth.new(session)
        shib.set_data(@user.shib_token.data)
        @shib_provider = shib.get_identity_provider
      end
    end
  end

  def update
    # map cropping attributes to be attributes of the profile
    [:crop_x, :crop_y, :crop_w, :crop_h, :crop_img_w, :crop_img_h].each do |attr|
      if params['user'] && params['user'][attr.to_s]
        @user.profile.send("#{attr}=", params['user'][attr.to_s])
        params['user'].delete(attr.to_s)
      end
    end
    @user.profile.crop_avatar

    password_changed = false
    if current_site.local_auth_enabled?
      password_changed =
        params[:user].present? &&
        params[:user].has_key?(:password) &&
        !params[:user][:password].empty?
    end

    if params[:user] && params[:user].has_key?(:superuser)
      is_superuser = parse_boolean(params[:user].delete(:superuser))
      if current_user.superuser? && current_user != @user
        @user.set_superuser!(is_superuser)
      end
    end

    if password_changed
      if current_user.superuser?
        params[:user].delete(:current_password) unless params[:user].nil?
        updated = @user.update_attributes(user_params)
      else
        updated = @user.update_with_password(user_params)
      end
    else
      params[:user].delete(:current_password) unless params[:user].nil?
      updated = @user.update_without_password(user_params)
    end

    if updated
      # User editing himself
      # Sign in the user bypassing validation in case his password changed
      sign_in @user, bypass: true if current_user == @user

      flash = { success: t("user.updated") }
      redirect_to_p edit_user_path(@user), :flash => flash
    else
      flash = { error: t("user.not_updated") }
      render_p :edit, flash: flash
    end
  end

  def destroy
    destroy! { manage_users_path }
  end

  # Returns fellows users - users that a members of spaces
  # the current user is also a member
  # TODO: should use the same base method for the action select, but filtering
  #   for fellows too
  def fellows
    @users = current_user.fellows(params[:q], params[:limit])

    respond_with @users do |format|
      format.json
    end
  end

  # Returns info of the current user
  def current
    @user = current_user
    respond_with(@user)
  end

  # Confirms a user's account
  def confirm
    if !@user.confirmed?
      @user.confirm
      flash[:notice] = t('users.confirm.confirmed', :username => @user.username)
    end
    redirect_to :back
  end

  # Methods to let admins create new users
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params.merge('approved' => true))
    @user.created_by = current_user
    @user.skip_confirmation_notification!

    respond_to do |format|

      if @user.save
        @user.confirm
        flash[:success] = t("users.create.success")
      else
        flash[:error] = t('users.create.error', errors: @user.errors.full_messages.join(", "))
      end

      format.html { redirect_to manage_users_path }
    end
  end

  def update_logo
    @user.profile.logo_image = params[:uploaded_file]

    if @user.profile.save
      url = logo_images_crop_path(model_type: 'user', model_id: @user)
      respond_to do |format|
        format.json {
          render json: {
                   success: true, redirect_url: url, small_image: @user.profile.small_logo_image?,
                   new_url: @user.profile.logo_image.url
                 }
        }
      end
    else
      respond_to do |format|
        format.json { render json: { success: false } }
      end
    end
  end

  private

  def load_and_authorize_with_disabled
    @user = User.with_disabled.where(username: params[:id]).first
    authorize! action_name.to_sym, @user
  end

  def require_approval?
    current_site.require_registration_approval?
  end

  def disable_notice
    if current_user == @user
      # the same message devise users when removing a registration
      t('devise.registrations.destroyed')
    else
      t('flash.users.disable.notice', :username => @user.username)
    end
  end

  def disable_back_path
    if current_user.superuser?
      manage_users_path
    else
      root_path
    end
  end

  allow_params_for :user
  def allowed_params
    allowed =  [
      :remember_me, :login, :timezone,
      profile_attributes: [ :address, :city, :province, :country, :zipcode, :phone,
                            :full_name, :organization, :description, :url,
                            :crop_x, :crop_y, :crop_w, :crop_h, :crop_img_w, :crop_img_h ]
    ]
    allowed += [:password, :password_confirmation, :current_password] if can?(:update_password, @user)
    allowed += [:email, :username] if current_user.superuser? and (params[:action] == 'create')
    allowed += [:approved, :disabled, :can_record] if current_user.superuser?
    allowed
  end

end
