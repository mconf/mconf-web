class BigbluebuttonRailsTo140C < ActiveRecord::Migration
  def up
    create_table :bigbluebutton_room_options do |t|
      t.integer :room_id
      t.string :default_layout
      t.timestamps
    end
    add_index :bigbluebutton_room_options, :room_id
  end

  def down
    drop_table :bigbluebutton_room_options
  end
end
