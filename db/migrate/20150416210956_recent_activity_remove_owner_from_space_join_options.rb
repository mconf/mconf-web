class RecentActivityRemoveOwnerFromSpaceJoinOptions < ActiveRecord::Migration
  def up
    RecentActivity.where(key: ["space.accept", "space.decline"], owner_type: "Space").each do |ra|
      ra.owner = nil
      ra.notified = true
      ra.save!
    end
  end

  def down
    RecentActivity.where(key: ["space.accept", "space.decline"], owner_type: "Space").each do |ra|
      ra.owner = ra.trackable
      ra.notified = false
      ra.save!
    end
  end
end
