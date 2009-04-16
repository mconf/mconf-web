class SiteExceptionNotifications < ActiveRecord::Migration
  def self.up
    add_column :sites, :exception_notifications, :boolean, :default => false
    add_column :sites, :exception_notifications_email, :string
  end

  def self.down
    remove_column :sites, :exception_notifications
    remove_column :sites, :exception_notifications_email
  end
end
