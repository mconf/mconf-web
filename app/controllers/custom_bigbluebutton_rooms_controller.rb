class CustomBigbluebuttonRoomsController < Bigbluebutton::RoomsController
  before_filter :authentication_required, :except => [:invite, :auth, :running]
  authorization_filter :manage, :current_site, :except => [:invite, :auth, :running, :join]
end
