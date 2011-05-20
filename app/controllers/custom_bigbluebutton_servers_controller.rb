class CustomBigbluebuttonServersController < Bigbluebutton::ServersController
  authorization_filter :manage, :current_site
end
