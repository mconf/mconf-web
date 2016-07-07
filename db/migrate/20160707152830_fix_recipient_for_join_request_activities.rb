class FixRecipientForJoinRequestActivities < ActiveRecord::Migration
  def up
    scope = RecentActivity.where(recipient_id: nil)

    puts "Migrating keys: 'join_request.no_accept'"
    scope.where(key: ["join_request.no_accept"]).find_each do |act|
      act.update_attributes(recipient_id: act.parameters[:candidate_id], recipient_type: 'User')
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
