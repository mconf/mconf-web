class BigbluebuttonRailsTo230B < ActiveRecord::Migration
  def change
    BigbluebuttonPlaybackType.find_each do |type|
      downloadable = BigbluebuttonRails.configuration.downloadable_playback_types.include?(type.identifier)
      type.update_attributes(downloadable: downloadable)
    end
  end
end
