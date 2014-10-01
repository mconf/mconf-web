# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "digest/sha1"
class UsersController < ApplicationController

  load_and_authorize_resource :find_by => :username, :except => [:enable, :index]
  before_filter :load_and_authorize_with_disabled, :only => [:enable]

  # #index is nested in spaces
  load_and_authorize_resource :space, :find_by => :permalink, :only => [:index]
  load_and_authorize_resource :through => :space, :only => [:index]
  before_filter :webconf_room!, :only => [:index]

  # Rescue username not found rendering a 404
  rescue_from ActiveRecord::RecordNotFound, :with => :render_404

  rescue_from CanCan::AccessDenied, :with => :handle_access_denied

  def handle_access_denied exception
    if @space.blank?
      redirect_to register_path
    else
      render_403(exception)
    end
  end

  respond_to :html, :except => [:select, :current, :fellows]
  respond_to :js, :only => [:select, :current, :fellows]
  respond_to :xml, :only => [:current]

  def index
    @users = @space.users.sort {|x,y| x.name <=> y.name }
    respond_to do |format|
      format.html { render :layout => 'spaces_show' }
    end
  end

  def show
    @user_spaces = @user.spaces
    @recent_activities = @user.all_activity.order('updated_at DESC').page(params[:page])
    @profile = @user.profile!
    respond_to do |format|
      format.html { render 'profiles/show' }
    end
  end

  def edit
    if current_user == @user # user editing himself
      shib = Mconf::Shibboleth.new(session)
      @shib_provider = shib.get_identity_provider
    end
    render :layout => 'no_sidebar'
  end

  def update
    password_changed = false
    if current_site.local_auth_enabled?
      password_changed =
        !params[:user].nil? && params[:user].has_key?(:password) &&
        !params[:user][:password].empty?
    end
    updated = if password_changed
                @user.update_with_password(user_params)
              else
                params[:user].delete(:current_password) unless params[:user].nil?
                @user.update_without_password(user_params)
              end

    if updated
      # User editing himself
      # Sign in the user bypassing validation in case his password changed
      sign_in @user, :bypass => true if current_user == @user

      flash = { :success => t("user.updated") }
      redirect_to edit_user_path(@user), :flash => flash
    else
      render "edit", :layout => 'no_sidebar'
    end
  end

  def destroy
    @user.disable

    if current_user == @user
      # the same message devise users when removing a registration
      flash[:notice] = t('devise.registrations.destroyed')
    else
      flash[:notice] = t('user.disabled', :username => @user.username)
    end

    respond_to do |format|
      format.html {
        if current_user.superuser?
          redirect_to manage_users_path
        else
          redirect_to root_path
        end
      }
    end
  end

  def enable
    unless @user.disabled?
      flash[:notice] = t('user.error.enabled', :name => @user.username)
    else
      @user.enable
      flash[:success] = t('user.enabled')
    end
    respond_to do |format|
      format.html { redirect_to manage_users_path }
    end
  end

  # Finds users by id (params[:i]) or by name, username or email (params[:q]) and returns
  # a list of a few selected attributes
  # TODO: This is used in a lot of places, but not all want all the filters and all the
  #  results. We could make it configurable.
  def select
    name = params[:q]
    id = params[:i]
    limit = params[:limit] || 5   # default to 5
    limit = 50 if limit.to_i > 50 # no more than 50
    query = User.joins(:profile).includes(:profile).order("profiles.full_name")
    if id
      @users = query.find_by_id(id)
    elsif query.nil?
      @users = query.limit(limit)
    else
      @users = query
        .where("profiles.full_name like ? OR users.username like ? OR users.email like ?", "%#{name}%", "%#{name}%", "%#{name}%")
        .limit(limit)
    end

    respond_with @users do |format|
      format.json
    end
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
    respond_with @user do |format|
      format.xml
      format.json
    end
  end

  def approve
    if Site.current.require_registration_approval?
      @user.approve!
      @user.skip_confirmation_notification!
      @user.confirm!
      flash[:notice] = t('users.approve.approved', :username => @user.username)
    else
      flash[:error] = t('users.approve.not_enabled')
    end
    redirect_to :back
  end

  def disapprove
    if Site.current.require_registration_approval?
      @user.disapprove!
      flash[:notice] = t('users.disapprove.disapproved', :username => @user.username)
    else
      flash[:error] = t('users.disapprove.not_enabled')
    end
    redirect_to :back
  end

  private

  def load_and_authorize_with_disabled
    @user = User.with_disabled.where(username: params[:id]).first
    authorize! :enable, @user
  end

  allow_params_for :user
  def allowed_params
    allowed = [ :password, :password_confirmation, :remember_me, :current_password,
      :login, :approved, :disabled, :timezone, :can_record, :receive_digest, :notification,
      :expanded_post ]

    allowed += [:superuser] if current_user.superuser? && current_user != @user
    allowed
  end

end
