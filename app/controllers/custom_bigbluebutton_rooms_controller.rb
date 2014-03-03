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

  load_and_authorize_resource :find_by => :param, :class => "BigbluebuttonRoom", :except => :create

  # TODO: cancan is not ready yet for strong_parameters, so if we call 'load_resource' on :create it
  # will try to create the resource and will fail with ActiveModel::ForbiddenAttributes
  # This should be solved in the future, so the block below (and the :except in the
  # 'load_and_authorize_resource' call above) can be removed.
  # See more at: https://github.com/ryanb/cancan/issues/835
  before_filter :load_room_for_create, :only => :create
  authorize_resource :find_by => :param, :class => "BigbluebuttonRoom", :only => :create
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
    @success_messages = Array.new
    @fail_messages = Array.new
    @fail_user_email = Array.new
    @fail_email = Array.new

    success = ""
    error = ""
    send_invite_webconference

    respond_to do |format|
      if @fail_messages.empty?
        if success.size != 0
          flash[:success] = success.html_safe
        end
        if error.size != 0
          flash[:error] = error.html_safe
        end
        format.html { redirect_to request.referer }
        format.xml  { render :xml => @success_messages, :status => :created, :location => @success_messages }
      else
        if success.size != 0
          flash[:success] = success.html_safe
        end
        if error.size != 0
          flash[:error] = error.html_safe
        end
        format.html { redirect_to request.referer }
        format.xml  { render :xml => @fail_messages.map{|m| m.errors}, :status => :unprocessable_entity }
      end
    end
  end

  protected

  # TODO: refactor, move things to a model, cleanup
  def send_invite_webconference
    users = params[:invite][:users].split(",")

    success = ""
    priv_msg = Hash.new
    priv_email = Hash.new

    priv_msg[:sender_id] = current_user.id
    priv_email[:sender_id] = current_user.id

    unless params[:invite][:message].empty?
      priv_email[:body] = params[:invite][:message]
    end
    priv_email[:room_name] = params[:invite][:room_name]
    priv_email[:room_url] = params[:invite][:room_url]
    priv_email[:mobile_url] = params[:invite][:mobile_url]
    priv_email[:user_name] = current_user.name
    priv_email[:locale] = get_user_locale(current_user)

    for userStr in users
      user = User.find_by_id(userStr)
      if user

        # TODO: check if the user wants email or private message

        priv_msg[:receiver_id] = user.id
        I18n.with_locale(get_user_locale(user, false)) do
          # TODO: would be better to render the email view in a variable and send it as private message
          priv_msg[:title] = t('notifier.webconference_invite_email.subject')
          body = t('notifier.webconference_invite_email.body', :sender => current_user.name, :name => params[:invite][:room_name],
                   :invite_url => params[:invite][:room_url],
                   :mobile_url => params[:invite][:mobile_url],
                   :email_sender => current_user.email).html_safe
          body += "</br>\"#{params[:invite][:message]}\"".html_safe
          priv_msg[:body] = body
        end
        private_message = PrivateMessage.new(priv_msg)
        if private_message.save
          @success_messages << private_message
          success = t('invite.invitation_successfully') << " " << t('invite.user_private_msg', :user => private_message.receiver.full_name)
        else
          error = t('invite.invitation_unsuccessfully') << " " << t('invite.user_private_msg', :user => private_message.receiver.full_name)
          @fail_messages << private_message
        end

        priv_email[:email_receiver] = user.email
        priv_email[:email_sender] = current_user.email
        priv_email[:locale] = get_user_locale(user, false)
        # TODO: what if the date is in another language/format?
        if params[:invite][:starts_on]
          params[:invite][:starts_on] = DateTime.strptime(params[:invite][:starts_on], "%d/%m/%Y %H:%M")
        end
        if params[:invite][:ends_on]
          params[:invite][:ends_on] = DateTime.strptime(params[:invite][:ends_on], "%d/%m/%Y %H:%M")
        end
        # Notifier.delay.webconference_invite_email(priv_email)
        Notifier.webconference_invite_email(@room, current_user, user, params[:invite]).deliver
        if success.size == 0
          success = t('invite.invitation_successfully') << " " << t('invite.email', :email => user.email)
        else
          success << ", " << t('invite.email', :email => user.email)
        end

      else

        email = userStr
        if valid_email?(email)
          priv_email[:email_receiver] = email
          priv_email[:email_sender] = current_user.email
          # Notifier.delay.webconference_invite_email(priv_email)
          # TODO: what if the date is in another language/format?
          if params[:invite][:starts_on]
            params[:invite][:starts_on] = DateTime.strptime(params[:invite][:starts_on], "%d/%m/%Y %H:%M")
          end
          if params[:invite][:ends_on]
            params[:invite][:ends_on] = DateTime.strptime(params[:invite][:ends_on], "%d/%m/%Y %H:%M")
          end
          Notifier.webconference_invite_email(@room, current_user, email, params[:invite]).deliver
          if success.size == 0
            success = t('invite.invitation_successfully') << " " << t('invite.email', :email => email)
          else
            success << ", " << t('invite.email', :email => email)
          end
        else
          if error.size == 0
            error = t('invite.invitation_unsuccessfully') << " " <<  t('invite.email', :email => email) << " " << t('invite.bad_format')
          else
            error << ", " <<  t('invite.email', :email => email) << " " << t('invite.bad_format')
          end
        end

      end
    end

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
