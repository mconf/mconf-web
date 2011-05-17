class CustomBigbluebuttonServersController < Bigbluebutton::ServersController
  before_filter :authentication_required
end
