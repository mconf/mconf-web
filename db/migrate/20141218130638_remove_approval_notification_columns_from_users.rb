class RemoveApprovalNotificationColumnsFromUsers < ActiveRecord::Migration

  def up
    remove_column :users, :needs_approval_notification_sent_at
    remove_column :users, :approved_notification_sent_at
  end

  def down
    add_column :users, :needs_approval_notification_sent_at
    add_column :users, :approved_notification_sent_at
    # When restoring the columns, set them to the actual time to avoid messy situations
    connection = ActiveRecord::Base.connection()
    now = Time.now.to_s(:db)
    sql = "UPDATE `users` SET `needs_approval_notification_sent_at` = '#{now}', `approved_notification_sent_at` = '#{now}';"
    connection.execute sql
  end
end
