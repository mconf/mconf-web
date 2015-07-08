# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'version'

module CustomBigbluebuttonPlaybackTypesHelper

  def link_to_playback(recording, playback, options={})
    link_params = { type: playback.format_type }

    if playback.identifier == 'presentation_video'
      name = if recording.description.blank?
               recording.name
             else
               recording.description
             end
      options.merge!(download: name.parameterize('_'))
      link_params.merge!(name: name.parameterize('_'))
    end

    link_to playback.name, play_bigbluebutton_recording_path(recording, link_params),
            options_for_tooltip(t("bigbluebutton_rails.playback_types.#{playback.identifier}.tip"), options)
  end

end
