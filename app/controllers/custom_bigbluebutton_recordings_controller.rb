class CustomBigbluebuttonRecordingsController < Bigbluebutton::RecordingsController
  # need authentication even to play a recording
  before_filter :authenticate_user!

  before_filter :set_parameters, only: :play

  load_and_authorize_resource :find_by => :recordid, :class => "BigbluebuttonRecording"

  protected

  # Checks the URL and sets the parameters as temporary parameters in the playback's URL.
  def set_parameters
    if params[:name] && @playback.present?
      url = Addressable::URI.parse(@playback.url)
      url.query_values = { name: params[:name] }
      url = url.to_s
      @playback.url = url
    end
  end

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
