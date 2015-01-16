class CustomBigbluebuttonPlaybackTypesController < Bigbluebutton::PlaybackTypesController

  # Only admins can do anything with playback types
  before_filter :authenticate_user!
  load_and_authorize_resource :find_by => :id, :class => "BigbluebuttonPlaybackType"

  def index
    @playback_types = BigbluebuttonPlaybackType.all
  end
end
