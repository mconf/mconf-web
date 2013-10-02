# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class SpacesController < ApplicationController

  before_filter :authenticate_user!, :only => [:new, :create]

  load_and_authorize_resource :find_by => :permalink

  # all actions that render the sidebar
  before_filter :webconf_room!,
    :only => [:show, :edit, :join_request_new, :user_permissions, :webconference, :recordings]

  before_filter :load_spaces_examples, :only => [:new, :create]

  # TODO: cleanup the other actions adding respond_to blocks here
  respond_to :js, :only => [:index, :show]
  respond_to :html, :only => [:new, :edit, :index, :show]

  # User trying to access a space not owned or joined by him
  rescue_from CanCan::AccessDenied do |exception|
    if user_signed_in? and not [:destroy, :update, :join_request_new].include?(exception.action)
      # Normal actions trigger a redirect to ask for membership
      flash[:error] = t("join_request.message_title")
      redirect_to new_space_join_request_path :id => params[:id]
    else
      # Logged out users or destructive actions are redirect to the 403 error
      flash[:error] = t("space.access_forbidden")
      render :template => "/errors/error_403", :status => 403, :layout => "error"
    end
  end

  # Create recent activity
  after_filter :only => [:create, :update, :leave] do
    @space.new_activity params[:action], current_user unless @space.errors.any?
  end

  # Recent activity for join requests
  after_filter :only => [:join_request_update] do
    @space.new_activity :join, current_user unless @join_request.errors.any? || !@join_request.accepted?
  end

  def index
    #if params[:space_id] && params[:space_id] != "all" && params[:space_id] !="my" && params[:space_id] !=""
    #  redirect_to space_path(Space.find_by_permalink(params[:space_id]))
    #  return
    #end
    if params[:view].nil? or params[:view] != "list"
      params[:view] = "thumbnails"
    end
    @spaces = Space.order('name ASC').all
    @private_spaces = @spaces.select{|s| !s.public?}
    @public_spaces = @spaces.select{|s| s.public?}

    if user_signed_in? && current_user.spaces.any?
      @user_spaces = current_user.spaces
    else
      @user_spaces = []
    end

    if @space
       session[:current_tab] = "Spaces"
    end
    if params[:manage]
      session[:current_tab] = "Manage"
      session[:current_sub_tab] = "Spaces"
    end

    respond_with @spaces do |format|
      format.html { render :index }
      format.js {
        json = @spaces.to_json(space_to_json_hash)
        render :json => json, :callback => params[:callback]
      }
      format.xml { render :xml => @public_spaces }
    end
  end

  def show
    # news
    @news_position = params[:news_position] ? params[:news_position].to_i : 0
    @news = @space.news.order("updated_at DESC").all
    @news_position = @news.length-1 if @news_position >= @news.length
    @news_to_show = @news[@news_position]

    # posts
    posts = @space.posts.not_events
    @latest_posts = posts.where(:parent_id => nil).where('author_id is not null').order("updated_at DESC").first(3)

    # users
    @latest_users = @space.users.order("permissions.created_at DESC").first(3)

    # events
    @upcoming_events = @space.events.order("start_date ASC").select{|e| e.start_date && e.start_date.future? }.first(5)
    @current_events = @space.events.order("start_date ASC").select{|e| e.start_date && !e.start_date.future? && e.end_date.future?}

    # role of the current user
    @permission = Permission.where(:user_id => current_user, :subject_id => @space, :subject_type => 'Space').first

    respond_to do |format|
      format.html { render :layout => 'spaces_show' }
      format.js {
        json = @space.to_json(space_to_json_hash)
        render :json => json, :callback => params[:callback]
      }
    end
  end

  def new
    @space = Space.new
    respond_with @space do |format|
      format.html { render :layout => 'application' }
    end
  end

  def create
    @space = Space.new(params[:space])

    if @space.save
      respond_with @space do |format|

        # the user that created the space is always an admin
        @space.add_member!(current_user, 'Admin')

        flash[:success] = t('space.created')
        format.html { redirect_to :action => "show", :id => @space  }
      end
    else
      respond_with @space do |format|
        format.html { render :new, :layout => "application" }
      end
    end
  end

  def edit
    render :layout => 'spaces_show'
  end

  def update
    unless params[:space][:bigbluebutton_room_attributes].blank?
      params[:space][:bigbluebutton_room_attributes][:id] = @space.bigbluebutton_room.id
    end

    if @space.update_attributes(space_params)
      respond_to do |format|
        if params[:space][:logo_image].present?
          format.html { redirect_to logo_images_crop_path(:model_type => 'space', :model_id => @space) }
        else
          format.html {
            flash[:success] = t('space.updated')
            redirect_to edit_space_path(@space)
          }
        end
      end
    else
      respond_to do |format|
        flash[:error] = t('error.change')
        format.html { redirect_to edit_space_path(@space) }
      end
    end
  end

  def destroy
    @space_destroy = Space.find_with_param(params[:id])
    @space_destroy.disable
    respond_to do |format|
      format.html {
        if request.referer.present? && request.referer.include?("manage") && current_user.superuser?
          flash[:notice] = t('space.disabled')
          redirect_to manage_spaces_path
        else
          flash[:notice] = t('space.deleted')
          redirect_to(spaces_path)
        end
      }
    end
  end

  def user_permissions
    @users = @space.users.order("name ASC")
    @permissions = space.permissions.sort{
      |x,y| x.user.name <=> y.user.name
    }
    @roles = Space.roles
    render :layout => 'spaces_show'
  end

  def enable
    unless @space.disabled?
      flash[:notice] = t('space.error.enabled', :name => @space.name)
      redirect_to request.referer
      return
    end

    @space.enable

    flash[:success] = t('space.enabled')
    respond_to do |format|
      format.html { redirect_to manage_spaces_path }
    end
  end

  def leave
    permission = @space.permissions.find_by_user_id(current_user)

    if permission
      permission.destroy
      respond_to do |format|
        format.html {
          flash[:success] = t('space.leave.success', :space_name => @space.name)
          if can?(:read, @space)
            redirect_to space_path(@space)
          else
            redirect_to root_path
          end
        }
      end
    else
      respond_to do |format|
        format.html { redirect_to space_path(@space) }
      end
    end
  end

  # Action used to show a webconference room of a space
  # This action is here and not in CustomBigbluebuttonRoomsController because it seems out of place
  # there, the before_filters and other methods don't really match. It's more related to spaces then
  # to webconference rooms.
  def webconference
    # FIXME: Temporarily matching users by name, should use the userID
    @webconf_attendees = []
    unless @webconf_room.attendees.nil?
      @webconf_room.attendees.each do |attendee|
        profile = Profile.find(:all, :conditions => { "full_name" => attendee.full_name }).first
        unless profile.nil?
          @webconf_attendees << profile.user
        end
      end
    end
    render :layout => 'spaces_show'
  end

  # Action used to show the recordings of a space
  # This action is here and not in CustomBigbluebuttonRoomsController because it seems out of place
  # there, the before_filters and other methods don't really match. It's more related to spaces then
  # to webconference rooms.
  def recordings
    @recordings = @webconf_room.recordings.published().order("end_time DESC")
    if params[:limit]
      @recordings = @recordings.first(params[:limit].to_i)
    end
    if params[:partial]
      render :layout => false
    else
      render :layout => 'spaces_show'
    end
  end

  def join_request_index
    respond_to { |format| format.html }
  end

  def join_request_new
    @join_request = space.join_requests.new
    @user_is_admin = space.role_for?(current_user, :name => 'Admin')

    # If it's the admin inviting, list the invitable users
    if @user_is_admin
      @users = (User.all - space.users)
      @checked_users = []
    end

    render :layout => 'spaces_show'
  end

  def join_request_create

    # If it's the admin creating a new request (inviting) for his space
    if space.role_for?(current_user, :name => 'Admin')

      @join_requests = []

      @ids = params[:invitation_ids] || []
      # Invite each of the users
      @ids.each do |id|

        jr = space.join_requests.new(params[:join_request])

        user = User.find(id)
        jr.candidate = user
        jr.email = user.email
        jr.request_type = 'invite'
        jr.introducer = current_user

        @join_requests << jr
      end

      emails = split_emails(params[:invitation_mails])
      emails.each do |e|

        jr = space.join_requests.new(params[:join_request])

        user = User.find_by_email(e)
        jr.candidate = user
        jr.email = e
        jr.request_type = 'invite'
        jr.introducer = current_user

        @join_requests << jr
      end

      errors = []
      @join_requests.each { |jr| errors << [jr.email, jr.error_messages] if !jr.valid? }

      if errors.empty?
        @join_requests.each { |jr| jr.save(:validate => false) }
        flash[:notice] = t('join_request.sent')
      else
        flash[:notice] = t('join_request.error')
      end

      redirect_to new_space_join_request_path(space)

    else # It's a common user asking for membership in a space

      @join_request = space.join_requests.new(params[:join_request])
      @join_request.candidate = current_user
      @join_request.email = current_user.email
      @join_request.request_type = 'request'

      if @join_request.save
        flash[:notice] = t('join_request.created')
      else
        flash[:error] = t('join_request.error')
        # TODO: identify errors for better usability
        # flash[:error] << @join_request.errors.to_xml
      end

      if space.public
        redirect_to space_path(space)
      else
        redirect_to spaces_path
      end

    end

  end

  def join_request_update
    join_request.attributes = params[:join_request].except(:role)
    join_request.introducer = current_user if join_request.recently_processed?

    respond_to do |format|
      if join_request.save
        format.html {
          flash[:success] = ( join_request.recently_processed? ?
                            ( join_request.accepted? ? t('join_request.accepted') : t('join_request.discarded') ) :
                            t('join_request.updated'))
          redirect_to request.referer
        }
        if join_request.accepted?
          role = Role.find(params[:join_request][:role])
          space.add_member!(join_request.candidate, role.name)
          success = space.save
        end
      else
        format.html {
          flash[:error] = join_request.errors.to_xml
          redirect_to request.referer
        }
      end
    end
  end

  private

  def join_request
    @join_request ||= space.join_requests.find(params[:jr_id])
  end

  def space
    if params[:action] == "enable"
      @space ||= Space.find_with_disabled_and_param(params[:id])
    else
      @space ||= Space.find_with_param(params[:id])
    end
  end

  def space_to_json_hash
    { :methods => :user_count, :include => {:logo => { :only => [:height, :width], :methods => :logo_image_path } } }
  end

  def load_spaces_examples
    # TODO: RAND() is specific for mysql
    @spaces_examples = Space.order('RAND()').limit(3)
  end

  def space_params
    unless params[:space].nil?
      params[:space].permit(*space_allowed_params)
    else
      []
    end
  end

  def space_allowed_params
    [ :name, :description, :logo_image, :public, :permalink, :repository,
      :crop_x, :crop_y, :crop_w, :crop_h,
      :bigbluebutton_room_attributes =>
        [ :id, :attendee_password, :moderator_password ] ]
  end
end
