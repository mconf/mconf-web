class CustomBigbluebuttonRecordingsController < Bigbluebutton::RecordingsController
  # need authentication even to play a recording
  before_filter :authenticate_user!

  load_and_authorize_resource :find_by => :recordid, :class => "BigbluebuttonRecording"

  # Override the method used in Bigbluebutton::RecordingsController to set the 
  # parameter who will determine the name of the video to download.
  def play
    if params[:type]
      playback = @recording.playback_formats.where(:playback_type_id => BigbluebuttonPlaybackType.find_by_identifier(params[:type])).first
    else
      playback = @recording.default_playback_format || @recording.playback_formats.first
    end

    if params[:name]
      url = Addressable::URI.parse(playback.url)
      url.query_values = { name: params[:name] }
      url = url.to_s
    else
      url = playback.url
    end

    respond_with do |format|
      format.html {
        if playback
          redirect_to url
        else
          flash[:error] = t('bigbluebutton_rails.recordings.errors.play.no_format')
          redirect_to_using_params bigbluebutton_recording_url(@recording)
        end
      }
    end
  end

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
