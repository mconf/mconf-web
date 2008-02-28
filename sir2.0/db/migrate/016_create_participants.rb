class CreateParticipants < ActiveRecord::Migration
  def self.up
     create_table :participants do |t|
      t.column :event_id, :integer, :null=>false
      t.column :machine_id, :integer, :null=>false
      t.column :machine_id_connected_to, :integer, :null=>false
      t.column :role, :string, :null=>false, :limit=>40
      t.column :fec, :integer, :default=>'0', :null=>false, :limit=>2
      t.column :radiate_multicast, :integer, :default=>'0', :null=>false, :limit=>1
      t.column :description, :text, :null=>true
    end
    drop_table :event_participants
  end

  def self.down
    drop_table :participants
    create_table :participants do |t|
      t.column :event_id, :integer, :null=>false
      t.column :machine_id, :integer, :null=>false
      t.column :machine_id_connected_to, :integer, :null=>false
      t.column :role, :string, :null=>false, :limit=>40
      t.column :fec, :integer, :default=>'0', :null=>false, :limit=>2
      t.column :radiate_multicast, :integer, :default=>'0', :null=>false, :limit=>1
      t.column :description, :text, :null=>true
    end
  end
end
