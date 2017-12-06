# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class SpacesController < InheritedResources::Base
  include Mconf::ApprovalControllerModule # for approve, disapprove
  include Mconf::DisableControllerModule # for enable, disable
  include Mconf::SelectControllerModule # select

  before_filter :require_spaces_mod

  before_filter :authenticate_user!, :only => [:new, :create]

  # TODO: cleanup the other actions adding respond_to blocks here
  respond_to :js, :only => [:index, :show]
  respond_to :json, :only => [:update_logo]
  respond_to :html, :only => [:new, :edit, :index, :show, :destroy, :update]

  rescue_from ActiveRecord::RecordNotFound, :with => :handle_record_not_found

  # Cancan and inherited resources load
  defaults finder: :find_by_slug!
  before_filter :load_space_via_space_id, only: [:edit_recording]
  before_filter :load_spaces_index, only: [:index, :select]
  load_and_authorize_resource :find_by => :slug, :except => [:enable, :disable, :destroy]
  before_filter :load_and_authorize_with_disabled, :only => [:enable, :disable, :destroy]

  # all actions that render the web conference room snippet
  before_filter :webconf_room!, :only => [:show, :webconference, :meetings]

  before_filter :load_spaces_examples, only: [:new, :create]

  before_filter :load_events, only: :show

  # Create recent activity
  after_filter :only => [:create, :update, :update_logo, :leave] do
    @space.new_activity(params[:action], current_user) unless @space.errors.any?
  end

  # modals
  before_filter :force_modal, only: :edit_recording

  layout :determine_layout

  def determine_layout
    case params[:action].to_sym
    when :new, :create
      "navbar_bg"
    when :edit_recording
      false
    else
      "application"
    end
  end

  def index
    order_spaces
    paginate_spaces

    if request.xhr?
      render "spaces/_list_view", layout: false, locals: { spaces: @spaces, user_spaces: @user_spaces , extended: true }
    else
      set_menu_tab
      render :index
    end
  end

  def show
    @latest_posts = @space.latest_posts
    @latest_users = @space.latest_users
  end

  def create
    if @space.save
      respond_with @space do |format|

        # the user that created the space is always an admin
        @space.add_member!(current_user, 'Admin')

        # pre-approve the space if it's an admin creating it
        @space.approve! if can?(:approve, @space)

        flash[:notice] = if @space.approved?
          t('space.created')
        else
          t('space.created_waiting_moderation')
        end

        format.html { redirect_to action: "show", id: @space }
      end
    else
      respond_with @space do |format|
        format.html { render :new }
      end
    end
  end

  def update_logo
    @space.logo_image = params[:uploaded_file]

    if @space.save
      url = logo_images_crop_path(model_type: 'space', model_id: @space)
      respond_to do |format|
        format.json {
          render json: {
                   success: true, redirect_url: url, small_image: @space.small_logo_image?,
                   new_url: @space.logo_image.url
                 }
        }
      end
    else
      respond_to do |format|
        format.json { render json: { success: false } }
      end
    end
  end

  def update
    unless params[:space][:bigbluebutton_room_attributes].blank?
      params[:space][:bigbluebutton_room_attributes][:id] = @space.bigbluebutton_room.id
    end

    update! { :back }
  end

  def destroy
    destroy!(notice: t('space.deleted')) { manage_spaces_path }
  end

  def user_permissions
    @users = @space.users.order("name ASC")
    @permissions = @space.permissions_ordered_by_name
      .paginate(:page => params[:page], :per_page => 10)
    @roles = Space.roles
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
    @webconf_attendees = @webconf_room.current_attendees
    @meetings = BigbluebuttonMeeting.where(room: @webconf_room).with_recording().newest(5)
  end

  # Action used to show the meetings of a space
  # This action is here and not in CustomBigbluebuttonRoomsController because it seems out of place
  # there, the before_filters and other methods don't really match. It's more related to spaces then
  # to webconference rooms.
  def meetings

    @meetings = BigbluebuttonMeeting.where(room: @webconf_room)
    if params[:recordedonly] == 'false'
      @meetings = @meetings.with_or_without_recording()
    else
      @meetings = @meetings.with_recording()
    end
    @meetings = @meetings.newest

    @recording_count = @meetings.count
    if params[:limit]
      @meetings = @meetings.first(params[:limit].to_i)
    end
  end

  # Page to edit a recording.
  def edit_recording
    @redir_url = request.referer
    @recording = BigbluebuttonRecording.find_by_recordid(params[:id])
    authorize! :space_edit, @recording
  end

  private

  # Load the @spaces and @user_spaces variables
  # The @spaces variable will only contain approved spaces
  def load_spaces_index
    spaces = Space.where(approved: true)
    @user_spaces = user_signed_in? ? current_user.spaces : Space.none
    words = params[:q].try(:split, /\s+/)

    @spaces = params[:my_spaces] ? @user_spaces : spaces
    @spaces = params[:q] ? @spaces.search_by_terms(words, can?(:manage, Space)) : @spaces

    params[:tag] = "" if params[:tag].blank? || !params[:tag].split(ActsAsTaggableOn.delimiter).any?
    @spaces = params[:tag].blank? ? @spaces : @spaces.tagged_with(params[:tag])

    @spaces = @spaces.includes(:tags)
  end

  def order_spaces
    params[:order] = 'relevance' if params[:order].nil? || params[:order] != 'abc'

    if params[:order] == 'abc'
      @spaces = @spaces.order('name ASC')
    else
      @spaces = @spaces.order_by_relevance
    end
  end

  def paginate_spaces
    @spaces = @spaces.paginate(:page => params[:page], :per_page => 15)
  end

  # Should be on the view?
  def set_menu_tab
    session[:current_tab] = "Spaces" if @space

    if params[:manage]
      session[:current_tab] = "Manage"
      session[:current_sub_tab] = "Spaces"
    end
  end

  def load_and_authorize_with_disabled
    @space = Space.with_disabled.find_by(slug: params[:id])
    authorize! action_name.to_sym, @space
  end

  def load_spaces_examples
    # TODO: RAND() is specific for mysql
    @spaces_examples = Space.where(approved: true).order_by_activity.limit(20).sample(5)
  end

  def load_events
    @upcoming_events = @space.events.upcoming.order("start_on ASC").first(5)
    @current_events = @space.events.order("start_on ASC").select(&:is_happening_now?)
  end

  # For edit_recording
  def load_space_via_space_id
    @space = Space.find_by(slug: params[:space_id])
  end

  def handle_record_not_found(exception)
    @error_message = t("spaces.error.not_found", :slug => params[:id], :path => spaces_path)
    render_404 exception
  end

  # Custom handler for access denied errors, overrides method on ApplicationController.
  # Used to show messages better than a simple 403 for the users in some cases.
  def handle_access_denied(exception)

    # anonymous users are required to sign in
    if !user_signed_in?
      redirect_to login_path

    # if it's a logged user that tried to access a private or unnaproved space
    elsif [:show, :edit].include?(exception.action)

      if !@space.approved?
        flash[:error] = t("spaces.error.unapproved")
        redirect_to spaces_path
      else
        # redirect him to the page to ask permission to join
        # if the user already has a pending request, it will have a notice and links to
        # access the invitation/request
        redirect_to new_space_join_request_path(space_id: params[:id])
      end

    # when space creation is forbidden for users
    elsif [:create, :new].include?(exception.action)
      flash[:error] = t("spaces.error.creation_forbidden")
      redirect_to spaces_path

    # when the user can't leave the space because it's the last admin
    elsif [:leave].include?(exception.action) && @space.is_last_admin?(current_user)
      flash[:error] = t("spaces.error.last_admin_cant_leave")
      redirect_to space_path(@space)

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
    [ :name, :description, :logo_image, :public, :slug, :disabled, :repository,
      :crop_x, :crop_y, :crop_w, :crop_h, :crop_img_w, :crop_img_h, :tag_list,
      :bigbluebutton_room_attributes =>
        [ :id, :attendee_key, :moderator_key, :default_layout, :private, :welcome_msg ]
    ]
  end

  # For disable controller module
  def disable_back_path
    if request.referer.present? && request.referer.include?("manage") && current_user.superuser?
      manage_spaces_path
    else
      spaces_path
    end
  end

  def back_url
    request.referer
  end
end
