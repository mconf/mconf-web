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

  # some routes are accessible to everyone, but some of them will do the authorization
  # themselves (e.g. permissions for :join will change depending on the user and the target
  # room)
  load_resource :find_by => :param, :class => "BigbluebuttonRoom"
  authorize_resource :class => "BigbluebuttonRoom",
    :except => [:invite, :invite_userid, :join, :auth, :join_mobile, :running,
                :external, :external_auth]

  before_filter :check_redirect_to_invite, :only => [:invite_userid]
  before_filter :check_redirect_to_invite_userid, :only => [:invite]

  layout :determine_layout

  def determine_layout
    case params[:action].to_sym
    when :join_mobile
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
end
