class BigbluebuttonRailsTo200D < ActiveRecord::Migration
  def change
    create_table :bigbluebutton_playback_types do |t|
      t.string :identifier
      t.boolean :visible, :default => false
      t.boolean :default, :default => false
      t.timestamps
    end

    remove_column :bigbluebutton_playback_formats, :format_type
    add_column :bigbluebutton_playback_formats, :playback_type_id, :integer
  end
end
