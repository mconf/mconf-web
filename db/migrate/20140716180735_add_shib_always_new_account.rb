class AddShibAlwaysNewAccount < ActiveRecord::Migration
  def up
    add_column :sites, :shib_always_new_account, :boolean, :default => false
  end

  def down
    remove_column :sites, :shib_always_new_account
  end
end
