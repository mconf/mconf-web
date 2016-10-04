class AddCurrentLocalSignInAtToUsers < ActiveRecord::Migration
  def up
    add_column :users, :current_local_sign_in_at, :datetime
  end
   def down
    remove_column :users, :current_local_sign_in_at
  end
end
