class RecentActivityMoveUserFromParametersToRecipient < ActiveRecord::Migration
  def up
    RecentActivity.all.each do |act|
      if act.parameters[:user_id].present?
        act.recipient_id = act.parameters[:user_id]
        act.recipient_type = 'User'
        act.parameters.delete(:user_id)
        act.save!
      end
    end
  end

  def down
    RecentActivity.all.each do |act|
      if act.recipient_id.present?
        act.parameters[:user_id] = act.recipient_id
        act.recipient_id = nil
        act.recipient_type = nil
        act.save!
      end
    end
  end
end
