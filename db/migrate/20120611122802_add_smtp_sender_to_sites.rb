class AddSmtpSenderToSites < ActiveRecord::Migration
  def self.up
   add_column :sites , :smtp_sender, :string
  end

  def self.down
   remove_column :sites, :smtp_sender
  end
end
