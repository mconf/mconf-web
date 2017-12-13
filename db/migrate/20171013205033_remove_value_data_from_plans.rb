class RemoveValueDataFromPlans < ActiveRecord::Migration
  def up
    remove_column :plans, :item_price
    remove_column :plans, :base_price
    remove_column :plans, :max_users
  end

  def down
    add_column :plans, :item_price, :integer
    add_column :plans, :base_price, :integer
    add_column :plans, :max_users, :integer
  end

end
