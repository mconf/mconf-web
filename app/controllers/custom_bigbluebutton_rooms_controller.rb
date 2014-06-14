# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class CustomBigbluebuttonRoomsController < Bigbluebutton::RoomsController
  # the exceptions are all used in the invitation page and should be accessible even to
  # anonymous users
  before_filter :authenticate_user!,
    :except => [:invite, :invite_userid, :auth, :running]

  # do it in 3 steps because we need more info about the room when joining/ending to decide
  # if the user has permissions and which role he should have in the meeting
  load_resource :find_by => :param, :class => "BigbluebuttonRoom", :instance_name => "room",
    :except => :create
  before_filter :fetch_room_info, :only => [:join, :end]
  authorize_resource :class => "BigbluebuttonRoom", :instance_name => "room",
    :except => :create

  # TODO: cancan is not ready yet for strong_parameters, so if we call 'load_resource' on :create it
  # will try to create the resource and will fail with ActiveModel::ForbiddenAttributes
  # This should be solved in the future, so the block below (and the :except in the
  # 'load_and_authorize_resource' call above) can be removed.
  # See more at: https://github.com/ryanb/cancan/issues/835
  before_filter :load_room_for_create, :only => :create
  authorize_resource :class => "BigbluebuttonRoom", :instance_name => "room",
    :only => :create
  def load_room_for_create
    @room = BigbluebuttonRoom.new(room_params)
  end

  # the logic of the 2-step joining process
  before_filter :check_redirect_to_invite, :only => [:invite_userid]
  before_filter :check_redirect_to_invite_userid, :only => [:invite]

  layout :determine_layout

  def determine_layout
    case params[:action].to_sym
    when :join_mobile, :join_options
      if request.xhr?
        false
      else
        "application"
      end
    when :running
      false
    when :invite_userid, :invite, :auth
      "no_sidebar"
    else
      "application"
    end
  end

  def check_redirect_to_invite
    # already has a user or a user set in the URL, jump directly to the next step
    has_user_param = !params[:user].nil? and !params[:user][:name].blank?
    if user_signed_in?
      redirect_to invite_bigbluebutton_room_path(@room)
    elsif has_user_param
      redirect_to invite_bigbluebutton_room_path(@room, :user => { :name => params[:user][:name] })
    end
  end

  def check_redirect_to_invite_userid
    # no user logged and no user set in the URL, go back to the identification step
    if !user_signed_in? and (params[:user].nil? or params[:user][:name].blank?)
      redirect_to join_webconf_path(@room)
    end
  end

  def join_options
    # don't let the user access this dialog if he can't record meetings
    # or if the feature to automatically set the record flag is disabled in the site
    # an extra protection, since the views that point to this route filter this as well
    ability = Abilities.ability_for(current_user)
    if ability.can?(:record_meeting, @room) && !Site.current.webconf_auto_record
      begin
        @room.fetch_is_running?
      rescue BigBlueButton::BigBlueButtonException
      end
    else
      redirect_to join_bigbluebutton_room_path(@room)
    end
  end

  def invitation
    respond_to do |format|
      format.html {
        render :layout => false if request.xhr?
      }
    end
  end

  def send_invitation

    # adjusts the dates set by the user in the datetimepicker to dates we can set in the invitation
    unless adjust_dates_for_invitation(params)
      flash[:error] = t('custom_bigbluebutton_rooms.send_invitation.error_date_format')

    else
      # the invitation object to be sent
      invitation = Mconf::Invitation.new
      invitation.from = current_user
      invitation.room = @room
      invitation.starts_on = params[:invite][:starts_on]
      invitation.ends_on = params[:invite][:ends_on]
      invitation.title = params[:invite][:title] || t('web_conference_mailer.invitation_mail.event_name', :name => from.full_name)
      invitation.url = join_webconf_url(@room, :host => current_site.domain)
      invitation.description = params[:invite][:message]

      # send the invitation to all users
      # make `users` an array of Users and emails
      users = params[:invite][:users].split(",")
      users = users.map { |user_str|
        user = User.find_by_id(user_str)
        user ? user : user_str
      }
      succeeded, failed = Mconf::Invitation.send_batch(invitation, users)

      unless succeeded.empty?
        success_msg = t('custom_bigbluebutton_rooms.send_invitation.success') + " "
        success_msg += succeeded.map { |user|
          user.is_a?(User) ? user.full_name : user
        }.join(", ")
        flash[:success] = success_msg
      end
      unless failed.empty?
        error_msg = t('custom_bigbluebutton_rooms.send_invitation.error') + " "
        error_msg += failed.map { |user|
          user.is_a?(User) ? user.full_name : user
        }.join(", ")
        flash[:error] = error_msg
      end
    end

    respond_to do |format|
      format.html { redirect_to request.referer }
    end
  end

  protected

  # Fetches information of the target room from the web conference server.
  def fetch_room_info
    @room.fetch_is_running?
    @room.fetch_meeting_info if @room.is_running?
  end

  # Converts the date submitted from a datetimepicker to a DateTime.
  # These dates were configured by the user in the view assuming his time zone, so we need to set
  # this time zone in the object before parsing it.
  def adjust_dates_for_invitation(params)
    date_format = t('_other.datetimepicker.format_rails')
    user_time_zone = Mconf::Timezone.user_time_zone_offset(current_user)
    if params[:invite][:starts_on].present?
      time = "#{params[:invite]['starts_on_time(4i)']}:#{params[:invite]['starts_on_time(5i)']}"
      params[:invite][:starts_on] = "#{params[:invite][:starts_on]} #{time} #{user_time_zone}"
      params[:invite][:starts_on] = Time.strptime(params[:invite][:starts_on], date_format)
    end
    if params[:invite][:ends_on].present?
      time = "#{params[:invite]['ends_on_time(4i)']}:#{params[:invite]['ends_on_time(5i)']}"
      params[:invite][:ends_on] = "#{params[:invite][:ends_on]} #{time} #{user_time_zone}"
      params[:invite][:ends_on] = Time.strptime(params[:invite][:ends_on], date_format)
    end
    (1..5).each { |n| params[:invite].delete("starts_on_time(#{n}i)") }
    (1..5).each { |n| params[:invite].delete("ends_on_time(#{n}i)") }
    true
  rescue
    false
  end

  # Override the method used in Bigbluebutton::RoomsController to get the parameters the user is
  # allowed to use on update/create. Normal users can only update a few of the parameters of a room.
  def room_allowed_params
    if current_user.superuser
      super
    else
      [ :attendee_password, :moderator_password, :private, :record, :default_layout,
        :metadata_attributes => [ :id, :name, :content, :_destroy, :owner_id ] ]
    end
  end
end
