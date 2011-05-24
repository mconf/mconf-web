class CustomBigbluebuttonRoomsController < Bigbluebutton::RoomsController
  before_filter :authentication_required, :except => [:invite, :auth, :running]
  # TODO review it, see Issue #107
  # authorization_filter :manage, :current_site, :except => [:invite, :auth, :running, :join]
  layout :application, :except => [:join_mobile]
end
