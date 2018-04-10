class AddDisabledToSubscription < ActiveRecord::Migration
  def change
  	add_column :subscriptions, :disabled, :boolean, default: false
  end
end
