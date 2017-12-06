class BigbluebuttonRailsTo220b < ActiveRecord::Migration
  def up
    create_table :bigbluebutton_attendees do |t|
      t.string :user_id
      t.string :external_user_id
      t.string :user_name
      t.decimal :join_time, precision: 14, scale: 0
      t.decimal :left_time, precision: 14, scale: 0
      t.integer :bigbluebutton_meeting_id
    end

    add_column :bigbluebutton_meetings, :finish_time, :decimal, precision: 14, scale: 0
    add_column :bigbluebutton_meetings, :got_stats, :string
  end

  def down
    drop_table :bigbluebutton_attendees
    remove_column :bigbluebutton_meetings, :finish_time
    remove_column :bigbluebutton_meetings, :got_stats
  end
end
