class AddVcModeToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :vc_mode, :integer, :default => 0 # Event::VC_MODE.index(:in_person)
  end

  def self.down
    remove_column :events, :vc_mode
  end
end
