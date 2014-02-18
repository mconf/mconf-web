class BigbluebuttonRailsTo140C < ActiveRecord::Migration
  def up
    create_table :bigbluebutton_room_options do |t|
      t.integer :room_id
      t.string :default_layout
      t.timestamps
    end
    add_index :bigbluebutton_room_options, :room_id

    # Generate room_options for all rooms
    BigbluebuttonRoom.all.each do |room|
      room.build_room_options
      unless room.save
        puts "Error generating #room_options for a room!"
        puts "  - Error: #{room.errors.full_messages.inspect}"
        puts "  - Room: #{room.inspect}"
      end
    end
  end

  def down
    drop_table :bigbluebutton_room_options
  end
end
