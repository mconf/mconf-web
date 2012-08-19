class CustomBigbluebuttonRoomsController < Bigbluebutton::RoomsController
  before_filter :authenticate_user!,
    :except => [:invite, :auth, :running, :external]
  authorize_resource :class => "BigbluebuttonRoom",
    :except => [:invite, :auth, :running, :join, :end, :external, :join_mobile]
  layout 'application', :except => [:join_mobile]
end
