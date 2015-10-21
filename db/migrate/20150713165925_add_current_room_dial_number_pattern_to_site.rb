class AddCurrentRoomDialNumberPatternToSite < ActiveRecord::Migration
  def change
    add_column :sites, :current_room_dial_number_pattern, :integer
  end
end
