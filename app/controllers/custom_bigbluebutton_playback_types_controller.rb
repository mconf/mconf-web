# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class CustomBigbluebuttonPlaybackTypesController < Bigbluebutton::PlaybackTypesController

  # Only admins can do anything with playback types
  before_filter :authenticate_user!
  load_and_authorize_resource :find_by => :id, :class => "BigbluebuttonPlaybackType"

  layout "manage"

  def index
    @playback_types = BigbluebuttonPlaybackType.all
  end
end
