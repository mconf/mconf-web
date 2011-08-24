class ChangeLogoutUrlFromAllRooms < ActiveRecord::Migration
  def self.up
    BigbluebuttonRoom.all.each do |r|
      r.update_attributes(:logout_url => "/feedback/webconf/")
    end
  end

  def self.down
  end
end
