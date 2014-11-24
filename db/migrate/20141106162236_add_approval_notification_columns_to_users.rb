class AddApprovalNotificationColumnsToUsers < ActiveRecord::Migration
  def up
    add_column :users, :needs_approval_notification_sent_at, :datetime
    add_column :users, :approved_notification_sent_at, :datetime

    # assume all users up to now already received the notifications
    connection = ActiveRecord::Base.connection()
    now = Time.now.to_s(:db)
    sql = "UPDATE `users` SET `needs_approval_notification_sent_at` = '#{now}', `approved_notification_sent_at` = '#{now}';"
    connection.execute sql
  end

  def down
    remove_column :users, :needs_approval_notification_sent_at
    remove_column :users, :approved_notification_sent_at
  end
end
