class AddInterfacesToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :web_interface, :string
    add_column :events, :isabel_interface, :string
    add_column :events, :sip_interface, :string
  end

  def self.down
    remove_column :events, :web_interface
    remove_column :events, :isabel_interface
    remove_column :events, :sip_interface
  end
end