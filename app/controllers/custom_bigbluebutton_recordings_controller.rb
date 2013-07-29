class CustomBigbluebuttonRecordingsController < Bigbluebutton::RecordingsController
  # need authentication even to play a recording
  before_filter :authenticate_user!

  load_and_authorize_resource :find_by => :recordid, :class => "BigbluebuttonRecording"
end
