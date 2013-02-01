class CustomBigbluebuttonRecordingsController < Bigbluebutton::RecordingsController
  authorization_filter :manage, :current_site
end
