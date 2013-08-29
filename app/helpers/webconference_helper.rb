require 'version'

module WebconferenceHelper

  def mobile_google_play_link
    "https://play.google.com/store/apps/details?id=org.mconf.android.mconfmobile"
  end

  def mobile_google_play_image
    "https://developer.android.com/images/brand/#{I18n.locale}_generic_rgb_wo_45.png"
  end

  # Returns a BigbluebuttonMetadata model from the BigbluebuttonRoom `room` that has the
  # name `name`.
  def get_room_metadata(room, name)
    room.metadata.all.select{ |m| m.name == name }.first
  end

end
