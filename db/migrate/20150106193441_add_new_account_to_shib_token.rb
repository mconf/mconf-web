class AddNewAccountToShibToken < ActiveRecord::Migration
  def change
    add_column :shib_tokens, :new_account, :boolean
  end
end
