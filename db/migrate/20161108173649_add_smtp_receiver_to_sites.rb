class AddSmtpReceiverToSites < ActiveRecord::Migration
  def up
    add_column :sites, :smtp_receiver, :string
  end
   def down
    remove_column :sites, :smtp_receiver
  end
end
