class AddExceptionNotificationsPrefixToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :exception_notifications_prefix, :string
  end

  def self.down
    remove_column :sites, :exception_notifications_prefix
  end
end
