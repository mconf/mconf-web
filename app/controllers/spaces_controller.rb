# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class SpacesController < ApplicationController
  include Mconf::ApprovalControllerModule # for approve, disapprove

  before_filter :authenticate_user!, :only => [:new, :create]

  load_and_authorize_resource :find_by => :permalink, :except => [:edit_recording, :enable, :destroy, :disable]
  load_resource :find_by => :permalink, :parent => true, :only => [:edit_recording]
  before_filter :load_and_authorize_with_disabled, :only => [:enable, :disable, :destroy]

  # all actions that render the sidebar
  before_filter :webconf_room!,
    :only => [:show, :edit, :user_permissions, :webconference,
              :recordings, :edit_recording, :webconference_options]

  before_filter :load_spaces_examples, :only => [:new, :create]

  before_filter :load_events, :only => :show, :if => lambda { Mconf::Modules.mod_enabled?('events') }

  # TODO: cleanup the other actions adding respond_to blocks here
  respond_to :js, :only => [:index, :show]
  respond_to :json, :only => [:update_logo]
  respond_to :html, :only => [:new, :edit, :index, :show]

  rescue_from ActiveRecord::RecordNotFound, :with => :handle_record_not_found

  # Create recent activity
  after_filter :only => [:create, :update, :update_logo, :leave] do
    @space.new_activity(params[:action], current_user) unless @space.errors.any?
  end

  def index
    params[:view] = 'thumbnails' if params[:view].nil? || params[:view] != 'list'
    params[:order] = 'relevance' if params[:order].nil? || params[:order] != 'abc'

    spaces = Space.where(approved: true)
    @user_spaces = user_signed_in? ? current_user.spaces : Space.none

    @spaces = params[:my_spaces] ? @user_spaces : spaces
    if params[:order] == 'abc'
      @spaces = @spaces.order('name ASC').paginate(:page => params[:page], :per_page => 18)
    else
      @spaces = @spaces.order_by_activity.paginate(:page => params[:page], :per_page => 18)
    end

    session[:current_tab] = "Spaces" if @space

    if params[:manage]
      session[:current_tab] = "Manage"
      session[:current_sub_tab] = "Spaces"
    end

    respond_with @spaces do |format|
      format.html { render :index }
      format.json
    end
  end

  def show
    # posts
    posts = @space.posts
    @latest_posts = posts.where(:parent_id => nil).where('author_id is not null').order("updated_at DESC").first(3)

    # users
    @latest_users = @space.users.order("permissions.created_at DESC").first(3)

    respond_to do |format|
      format.html { render :layout => 'spaces_show' }
      format.json
    end
  end

  def new
    @space = Space.new
    respond_with @space do |format|
      format.html { render :layout => 'application' }
    end
  end

  def create
    @space = Space.new(space_params)

    if @space.save
      respond_with @space do |format|

        # the user that created the space is always an admin
        @space.add_member!(current_user, 'Admin')

        # pre-approve the space if it's an admin creating it
        @space.approve! if can?(:approve, @space)

        if @space.approved?
          flash[:success] = t('space.created')
        else
          flash[:success] = t('space.created_waiting_moderation')
        end
        format.html { redirect_to action: "show", id: @space }
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

  def update_logo
    @space.logo_image = params[:uploaded_file]

    if @space.save
      url = logo_images_crop_path(:model_type => 'space', :model_id => @space)
      respond_to do |format|
        format.json {
          render :json => {
            success: true, redirect_url: url, small_image: @space.small_logo_image?,
            new_url: @space.logo_image.url
          }
        }
      end
    else
      format.json { render json: { success: false } }
    end
  end

  def update
    unless params[:space][:bigbluebutton_room_attributes].blank?
      params[:space][:bigbluebutton_room_attributes][:id] = @space.bigbluebutton_room.id
    end

    if @space.update_attributes(space_params)
      respond_to do |format|
        format.html {
          flash[:success] = t('space.updated')
          redirect_to :back
        }
      end
    else
      respond_to do |format|
        flash[:error] = t('error.change')
        format.html { redirect_to :back }
      end
    end
  end

  def disable
    @space.disable
    respond_to do |format|
      format.html {
        flash[:notice] = t('space.disabled')
        if request.referer.present? && request.referer.include?("manage") && current_user.superuser?
          redirect_to manage_spaces_path
        else
          redirect_to spaces_path
        end
      }
    end
  end

  def destroy
    @space.destroy
    respond_to do |format|
      format.html {
        flash[:notice] = t('space.deleted')
        redirect_to manage_spaces_path
      }
    end
  end

  def user_permissions
    @users = @space.users.order("name ASC")
    @permissions = @space.permissions.sort{
      |x,y| x.user.name <=> y.user.name
    }
    @roles = Space.roles
    render :layout => 'spaces_show'
  end

  def webconference_options
    render :layout => 'spaces_show'
  end

  def enable
    unless @space.disabled?
      flash[:notice] = t('space.error.enabled', :name => @space.name)
    else
      @space.enable
      flash[:success] = t('space.enabled')
    end
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
          if can?(:show, @space)
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
        user = User.where(id: attendee.user_id).first
        @webconf_attendees << user unless user.nil?
      end
      @webconf_attendees.uniq!
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

  # Page to edit a recording.
  def edit_recording
    # @space = Space.find_by_permalink(params[:space_id])
    @redir_url = recordings_space_path(@space.to_param) # TODO: not working, no support on bbb_rails
    @recording = BigbluebuttonRecording.find_by_recordid(params[:id])
    authorize! :space_edit, @recording
    if request.xhr?
      render :layout => false
    else
      render :layout => "spaces_show"
    end
  end

  # Finds spaces by name (params[:q]) and returns a list of selected attributes
  def select
    name = params[:q]
    limit = params[:limit] || 5   # default to 5
    limit = 50 if limit.to_i > 50 # no more than 50
    if name.nil?
      @spaces = Space.where(approved: true).limit(limit).all
    else
      @spaces = Space.where("name like ?", "%#{name}%").where(approved: true).limit(limit)
    end

    respond_with @spaces do |format|
      format.json
    end
  end

  private

  def load_and_authorize_with_disabled
    @space = Space.with_disabled.find_by_permalink(params[:id])
    authorize! action_name.to_sym, @space
  end

  def load_spaces_examples
    # TODO: RAND() is specific for mysql
    @spaces_examples = Space.where(approved: true).order('RAND()').limit(3)
  end

  def load_events
    @upcoming_events = @space.events.upcoming.order("start_on ASC").first(5)
    @current_events = @space.events.order("start_on ASC").select(&:is_happening_now?)
  end

  def handle_record_not_found exception
    @error_message = t("spaces.error.not_found", :permalink => params[:id], :path => spaces_path)
    render_404 exception
  end

  # Custom handler for access denied errors, overrides method on ApplicationController.
  def handle_access_denied exception

    # anonymous users are required to sign in
    if !user_signed_in?
      redirect_to login_path

    # if it's a logged user that tried to access a private or unnaproved space
    elsif [:show, :edit].include?(exception.action)

      if !@space.approved?
        flash[:error] = t("spaces.error.unapproved")
        redirect_to spaces_path

      elsif @space.pending_join_request_for?(current_user)
        # redirect him to the page to ask permission to join, but with a warning that
        # a join request was already sent
        redirect_to new_space_join_request_path :space_id => params[:id]

      elsif @space.pending_invitation_for?(current_user)
        # redirect him to the invitation he received
        invitation = @space.pending_invitation_for(current_user)
        flash[:error] = t("spaces.error.already_invited")
        redirect_to space_join_request_path @space, invitation

      else
        # redirect him to ask permission to join
        flash[:error] = t("spaces.error.need_join_to_access")
        redirect_to new_space_join_request_path :space_id => params[:id]
      end

    # when space creation is forbidden for users
    elsif [:create, :new].include? exception.action
      flash[:error] = t("spaces.error.creation_forbidden")
      redirect_to spaces_path

    # destructive actions are redirected to the 403 error
    else
      flash[:error] = t("space.access_forbidden")
      if exception.action == :show
        @error_message = t("space.is_private_html", name: @space.name, path: new_space_join_request_path(@space))
      end
      render_403 exception
    end
  end

  def require_approval?
    current_site.require_space_approval?
  end

  allow_params_for :space
  def allowed_params
    [ :name, :description, :logo_image, :public, :permalink, :disabled, :repository,
      :crop_x, :crop_y, :crop_w, :crop_h, :crop_img_w, :crop_img_h,
      :bigbluebutton_room_attributes =>
        [ :id, :attendee_key, :moderator_key, :default_layout, :private,
          :welcome_msg, :presenter_share_only, :auto_start_video, :auto_start_audio ] ]
  end
end
