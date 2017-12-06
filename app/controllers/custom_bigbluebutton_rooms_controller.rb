# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class CustomBigbluebuttonRoomsController < Bigbluebutton::RoomsController
  # the exceptions are all used in the invitation page and should be accessible even to
  # anonymous users
  before_filter :authenticate_user!,
    :except => [:invite, :invite_userid, :join, :join_mobile, :running]

  # For :join and :end we need information from the web conference server, so we have to fetch it.
  # This has to run before any kind of authorization because some methods need this extra
  # information, see `ApplicationController.bigbluebutton_role`.
  load_resource find_by: :slug, class: "BigbluebuttonRoom",
    instance_name: "room", except: [:join, :end]
  prepend_before_action :load_and_fetch_room_info, only: [:join, :end]

  # Authorizing is the same for all actions
  authorize_resource class: "BigbluebuttonRoom", instance_name: "room"

  # can't join or join mobile if not logged and the site does not allow
  # unauthorized joins
  before_filter :check_unauth_access, only: [:join, :join_mobile, :invite]

  # the logic of the 2-step joining process
  before_filter :check_redirect_to_invite, only: [:invite_userid]
  before_filter :check_redirect_to_invite_userid, only: [:invite]

  # don't let users join if the room's limit was exceeded
  before_filter :check_user_limit, only: [:join]

  # modals
  before_filter :force_modal, only: [:user_edit, :invitation]

  # use the patter configured on the site to generate dial numbers
  before_filter :set_site_pattern, only: :generate_dial_number

  layout :determine_layout

  def determine_layout
    case params[:action].to_sym
    when :join_mobile
      "no_sidebar"
    when :running
      false
    when :invite_userid, :invite
      "navbar_bg"
    when :user_edit, :invitation
      false
    else
      "manage"
    end
  end

  def check_redirect_to_invite
    # already has a user or a user set in the URL, jump directly to the next step
    has_user_param = !params[:user].nil? and !params[:user][:name].blank?
    if user_signed_in? || guest_user_signed_in?
      redirect_to invite_bigbluebutton_room_path(@room)
    elsif has_user_param
      redirect_to invite_bigbluebutton_room_path(@room, user: { name: params[:user][:name] })
    end
  end

  def check_redirect_to_invite_userid
    # no user logged and no user set in the URL, go back to the identification step
    if !user_signed_in? &&
       !guest_user_signed_in? &&
       (params[:user].nil? or params[:user][:name].blank?)
      redirect_to join_webconf_path(@room)
    end
  end

  # Redirects the user to the identification page if not signed in and the
  # site does not allow unauthorized joins
  def check_unauth_access
    if !current_site.unauth_access_to_conferences && !user_signed_in? && !guest_user_signed_in?
      redirect_to join_webconf_path(id: params[:id])
      flash[:error] = t('custom_bigbluebutton_rooms.join.unauth_access_to_conferences')
    end
  end

  def invitation
  end

  def send_invitation
    # adjusts the dates set by the user in the datetimepicker to dates we can set in the invitation
    if !adjust_dates_for_invitation(params)
      flash[:error] = t('custom_bigbluebutton_rooms.send_invitation.error_date_format')

    elsif params[:invite][:title].blank?
      flash[:error] = t('custom_bigbluebutton_rooms.send_invitation.error_title')

    elsif params[:invite][:users].blank?
      flash[:error] = t('custom_bigbluebutton_rooms.send_invitation.blank_users')

    else
      user_list = "#{params[:invite][:users]},#{current_user.id}"
      invitations = WebConferenceInvitation.create_invitations user_list,
        invitation_group: SecureRandom.uuid,
        sender: current_user,
        target: @room,
        starts_on: params[:invite][:starts_on_time],
        duration: params[:invite][:duration].to_i,
        title: params[:invite][:title],
        url: join_webconf_url(@room),
        description: params[:invite][:message],
        ready: true

      # we do a check just to give a better response to the user, since the invitations will
      # only be sent in background later on
      succeeded, failed = WebConferenceInvitation.check_invitations(invitations)
      flash[:success] = WebConferenceInvitation.build_flash(
        succeeded, t('custom_bigbluebutton_rooms.send_invitation.success')) unless succeeded.empty?
      flash[:error] = WebConferenceInvitation.build_flash(
        failed, t('custom_bigbluebutton_rooms.send_invitation.error')) unless failed.empty?
    end

    redirect_to request.referer
  end

  # Called by users to edit a webconference room. It's different from the
  # standard CustomBigbluebuttonRoomsController#edit, that allows an admin to
  # edit *everything* in a room. This one is a lot more restricted.
  def user_edit
    @redir_url = request.referer
  end

  protected

  # Loads the room and fetches information from the web conference server.
  def load_and_fetch_room_info
    @room = BigbluebuttonRoom.find_by!(slug: params[:id])
    @room.fetch_is_running?
    @room.fetch_meeting_info if @room.is_running?
  end

  # Converts the date submitted from a datetimepicker to a DateTime.
  # These dates were configured by the user in the view assuming his time zone, so we need to set
  # this time zone in the object before parsing it.
  def adjust_dates_for_invitation(params)
    date_format = t('_other.datetimepicker.format_rails')
    user_time_zone = Mconf::Timezone.user_time_zone(current_user).name

    if params[:invite][:starts_on_time].present?
      params[:invite][:starts_on_time] = Mconf::Timezone.parse_in_timezone(params[:invite][:starts_on_time], user_time_zone, date_format)
      true
    else
      return false
    end
  rescue
    false
  end

  # Redirects the user elsewhere if the room exceeds the user limit defined in the room.
  # This check won't be made when the room is being created.
  # Note: Solves the problem but it's not perfect. Has concurrency problems if users try to join
  # simultaneously, before the webconf server has updated the number of participants to return
  # in the API. Ideally BBB should enforce max_participants is respected.
  def check_user_limit
    user_limit = @room.max_participants

    if user_limit.present? && @room.is_running?
      meeting = @room.fetch_meeting_info
      if meeting[:participantCount] >= user_limit
        flash[:error] = t('custom_bigbluebutton_rooms.join.user_limit_exceeded')
        redirect_to request.referer
      end
    end
  end

  def set_site_pattern
    params[:pattern] ||= Site.current.room_dial_number_pattern
  end

  # For cancan create load_and_authorize
  def create_params
    room_params
  end

  # Override the method used in Bigbluebutton::RoomsController to get the parameters the user is
  # allowed to use on update/create. Normal users can only update a few of the parameters of a room.
  def room_allowed_params
    if current_user.superuser
      super
    else
      [ :attendee_key, :private, :record_meeting, :default_layout, :name,
        :welcome_msg, :metadata_attributes => [ :id, :name, :content, :_destroy, :owner_id ] ]
    end
  end
end
