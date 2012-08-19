class CustomBigbluebuttonServersController < Bigbluebutton::ServersController
  before_filter :authenticate_user!
  authorize_resource :class => "BigbluebuttonServer"
end
