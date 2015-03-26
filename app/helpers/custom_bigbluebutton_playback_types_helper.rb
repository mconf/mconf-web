require 'version'

module CustomBigbluebuttonPlaybackTypesHelper

  def link_to_playback(recording, playback, options={})
  	link_params = { type: playback.format_type }
  	
  	if playback.identifier == "presentation_video"
  		options.merge!(download: recording.name.downcase.tr(" ", "_"))
  		link_params.merge!(name: recording.name.downcase.tr(" ", "_"))
  	end

  	link_to playback.name, play_bigbluebutton_recording_path(recording, link_params), options_for_tooltip(t("bigbluebutton_rails.playback_types.#{playback.identifier}.tip"), options)
  end

end