class BigbluebuttonRailsTo200F < ActiveRecord::Migration
  def up
    create_table :bigbluebutton_server_configs do |t|
      t.integer :server_id
      t.text :available_layouts
      t.timestamps
    end
  end

  def down
    drop_table :bigbluebutton_server_configs
  end
end
