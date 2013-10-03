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
    # an extra protection, since the views that point to this route filter this as well
    ability = Abilities.ability_for(current_user)
    if ability.can?(:record_meeting, @room)
      begin
        @room.fetch_is_running?
      rescue BigBlueButton::BigBlueButtonException
      end
    else
      redirect_to join_bigbluebutton_room_path(@room)
    end
  end

  protected

  # Override the method used in Bigbluebutton::RoomsController to get the parameters the user is
  # allowed to use on update/create. Normal users can only update a few of the parameters of a room.
  def room_allowed_params
    if current_user.superuser
      super
    else
      [ :attendee_password, :moderator_password, :private, :record,
        :metadata_attributes => [ :id, :name, :content, :_destroy, :owner_id ] ]
    end
  end
end
