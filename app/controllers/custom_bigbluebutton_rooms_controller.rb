class CustomBigbluebuttonRoomsController < Bigbluebutton::RoomsController
  before_filter :authentication_required, :except => [:invite, :auth, :running, :external, :invite_userid]
  authorization_filter :manage, :current_site, :except => [:invite, :auth, :running, :join, :end, :external, :join_mobile, :fetch_recordings, :invite_userid]

  layout :determine_layout
  def determine_layout
    case params[:action].to_sym
    when :join_mobile, :running
      false
    when :invite_userid, :invite, :auth
      "application_without_sidebar"
    else
      "application"
    end
  end

  before_filter :before_invite_userid, :only => [:invite_userid]
  def before_invite_userid
    has_user_param = !params[:user].nil? and !params[:user][:name].blank?
    if logged_in?
      redirect_to invite_bigbluebutton_room_path(@room)
    elsif has_user_param
      redirect_to invite_bigbluebutton_room_path(@room, :user => { :name => params[:user][:name] })
    end
  end

  before_filter :before_invite, :only => [:invite]
  def before_invite
    if !logged_in? and (params[:user].nil? or params[:user][:name].blank?)
      redirect_to join_webconf_path(@room)
    end
  end
end
