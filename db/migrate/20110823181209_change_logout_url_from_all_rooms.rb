class ChangeLogoutUrlFromAllRooms < ActiveRecord::Migration
  def self.up
    BigbluebuttonRoom.all.each do |r|
      r.logout_url = "/feedback/webconf/"
      r.save
    end
  end

  def self.down
  end
end
