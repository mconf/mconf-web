class CustomBigbluebuttonRoomsController < Bigbluebutton::RoomsController
  before_filter :authentication_required, :except => [:invite, :auth, :running, :external, :identification_webconf]
  authorization_filter :manage, :current_site, :except => [:invite, :auth, :running, :join, :end, :external, :join_mobile, :fetch_recordings, :identification_webconf]
  layout 'application', :except => [:join_mobile, :invite, :identification_webconf, :join, :auth]
  layout 'application_without_sidebar', :only => [:invite, :identification_webconf, :join, :auth]
  before_filter :before_invite, :only => [:invite]

  def before_invite
    if !logged_in? and (params[:user].nil? or params[:user][:name].blank?)
      redirect_to join_webconf_path
    end
  end
end
