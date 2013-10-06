class CustomBigbluebuttonRecordingsController < Bigbluebutton::RecordingsController
  # need authentication even to play a recording
  before_filter :authenticate_user!

  load_and_authorize_resource :find_by => :recordid, :class => "BigbluebuttonRecording"

  protected

  # Override the method used in Bigbluebutton::RecordingsController to get the parameters the
  # user is allowed to use on update/create. Normal users can only update a few of the parameters
  # of a recording.
  def recording_allowed_params
    if current_user.superuser
      super
    else
      [ :description ]
    end
  end
end
