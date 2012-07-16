class AddXmppServerToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :xmpp_server, :string
  end

  def self.down
    remove_column :sites, :xmpp_server
  end
end
