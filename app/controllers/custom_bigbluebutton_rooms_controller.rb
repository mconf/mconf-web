class CustomBigbluebuttonRoomsController < Bigbluebutton::RoomsController
  before_filter :authentication_required, :except => [:invite, :auth, :running, :external]
  authorization_filter :manage, :current_site, :except => [:invite, :auth, :running, :join, :end, :external, :join_mobile, :fetch_recordings]
  layout 'application', :except => [:join_mobile]
  layout 'application_without_sidebar', :only => [:invite]
end
