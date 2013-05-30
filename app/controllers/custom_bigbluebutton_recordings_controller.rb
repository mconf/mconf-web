class CustomBigbluebuttonRecordingsController < Bigbluebutton::RecordingsController
  # TODO: authorization
  # before_filter :authentication_required
  # authorization_filter :manage, :current_site, :except => [:play]
end
