class AddRoomDialNumberPatternToSite < ActiveRecord::Migration
  def change
    add_column :sites, :room_dial_number_pattern, :string
  end
end
