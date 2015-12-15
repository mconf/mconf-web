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

  respond_to :html, except: [:select, :current, :fellows]
  respond_to :json, only: [:select, :current, :fellows]
  respond_to :xml, only: [:current]

  defaults finder: :find_by_permalink!
  load_and_authorize_resource :find_by => :username, :except => [:enable, :index, :destroy]
  before_filter :load_and_authorize_with_disabled, :only => [:enable, :destroy]

  # Rescue username not found rendering a 404
  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  layout :set_layout
  def set_layout
    if [:index].include?(action_name.to_sym)
      'spaces_show'
    elsif [:edit].include?(action_name.to_sym)
      'no_sidebar'
    else
      'application'
    end
  end

  def index
    @space = Space.find_by_permalink!(params[:space_id])
    webconf_room!

    authorize! :show, @space

    @users = @space.users.sort {|x,y| x.name <=> y.name }
  end

  def show
    @user_spaces = @user.spaces

    # Show activity only in spaces where the current user is a member
    in_spaces = current_user.present? ? current_user.spaces : []
    @recent_activities = RecentActivity.user_public_activity(@user, in_spaces: in_spaces)
    @recent_activities = @recent_activities.order('updated_at DESC').page(params[:page])

    @profile = @user.profile
    respond_to do |format|
      format.html { render 'profiles/show' }
    end
  end

  def edit
    if current_user == @user # user editing himself
      shib = Mconf::Shibboleth.new(session)
      @shib_provider = shib.get_identity_provider
    end
  end

  def update
    password_changed = false
    if current_site.local_auth_enabled?
      password_changed =
        !params[:user].nil? && params[:user].has_key?(:password) &&
        !params[:user][:password].empty?
    end
    updated = if password_changed and !current_user.superuser?
                @user.update_with_password(user_params)
              elsif password_changed and current_user.superuser?
                params[:user].delete(:current_password) unless params[:user].nil?
                @user.update_attributes(user_params)
              else
                params[:user].delete(:current_password) unless params[:user].nil?
                @user.update_without_password(user_params)
              end

    if updated
      # User editing himself
      # Sign in the user bypassing validation in case his password changed
      sign_in @user, :bypass => true if current_user == @user

      flash = { :success => t("user.updated") }
      redirect_to params[:return_to] || edit_user_path(@user), :flash => flash
    else
      render "edit", :layout => 'no_sidebar'
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
    respond_to do |format|
      format.html { render layout: !request.xhr? }
    end
  end

  def create
    @user.created_by = current_user
    @user.skip_confirmation_notification!

    respond_to do |format|

      if @user.save
        @user.confirm
        @user.approve!
        flash[:success] = t("users.create.success")
      else
        flash[:error] = t('users.create.error', errors: @user.errors.full_messages.join(", "))
      end

      format.html { redirect_to manage_users_path }
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
    allowed = [ :remember_me, :login, :timezone, :receive_digest, :expanded_post ]
    allowed += [:password, :password_confirmation, :current_password] if can?(:update_password, @user)
    allowed += [:email, :username, :_full_name] if current_user.superuser? and (params[:action] == 'create')
    allowed += [:approved, :disabled, :can_record] if current_user.superuser?
    allowed += [:superuser] if current_user.superuser? && current_user != @user
    allowed
  end

end
