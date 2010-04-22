class CmEventsParameters < ActiveRecord::Migration
  def self.up
    add_column :events, :web_interface, :boolean, :default => false
    add_column :events, :isabel_interface, :boolean, :default => false
    add_column :events, :sip_interface, :boolean, :default => false
  end

  def self.down
    remove_column :events, :web_interface
    remove_column :events, :isabel_interface
    remove_column :events, :sip_interface
  end
end
