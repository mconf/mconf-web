class BigbluebuttonRailsTo005 < ActiveRecord::Migration

  def self.up
    add_column :bigbluebutton_rooms, :external, :boolean, :default => false
    add_column :bigbluebutton_rooms, :param, :string
    add_column :bigbluebutton_servers, :param, :string

    BigbluebuttonRoom.all.each do |r|
      r.update_attributes(:param => r.name.parameterize.downcase) unless r.name.nil?
    end
    BigbluebuttonServer.all.each do |s|
      s.update_attributes(:param => s.name.parameterize.downcase) unless s.name.nil?
    end

  end

  def self.down
    remove_column :bigbluebutton_rooms, :external
    remove_column :bigbluebutton_rooms, :param
    remove_column :bigbluebutton_servers, :param
  end

end
