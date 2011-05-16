class CustomBigbluebuttonRoomsController < Bigbluebutton::RoomsController
  before_filter :authentication_required, :except => [:invite, :auth, :running]
end
