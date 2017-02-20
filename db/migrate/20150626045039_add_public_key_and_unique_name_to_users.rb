class AddPublicKeyAndUniqueNameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :public_key, :text
    add_column :users, :unique_name, :string
  end
end
