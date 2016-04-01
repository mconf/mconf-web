class RemoveRecentActivitiesForPrivateMessages < ActiveRecord::Migration
  def up
    RecentActivity.where(trackable_type: 'PrivateMessage').destroy_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
