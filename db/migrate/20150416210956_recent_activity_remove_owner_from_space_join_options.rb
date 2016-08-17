class RecentActivityRemoveOwnerFromSpaceJoinOptions < ActiveRecord::Migration
  def up
    RecentActivity.where(key: ["space.accept", "space.decline"], owner_type: "Space").each do |ra|
      ra.update_attribute(:owner_id, nil)
      ra.update_attribute(:owner_type, nil)
      ra.update_attribute(:notified, true)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
