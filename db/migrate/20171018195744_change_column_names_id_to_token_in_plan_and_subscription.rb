class ChangeColumnNamesIdToTokenInPlanAndSubscription < ActiveRecord::Migration
  def up
    rename_column :subscriptions, :plan_id, :plan_token 
    rename_column :plans, :ops_id, :ops_token 
  end

  def down
    rename_column :subscriptions, :plan_token, :plan_id 
    rename_column :plans, :ops_token, :ops_id 
  end
end

