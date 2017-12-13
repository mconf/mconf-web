class ChangeSubscriptionPlanIdToOpsToken < ActiveRecord::Migration
  def up
    change_column :subscriptions, :plan_id, :string 
  end

  def down
    change_column :subscriptions, :plan_id, :integer 
  end
end
