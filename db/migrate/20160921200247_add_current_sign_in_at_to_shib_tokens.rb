class AddCurrentSignInAtToShibTokens < ActiveRecord::Migration
  def up
    add_column :shib_tokens, :current_sign_in_at, :datetime
  end
  def down
    remove_column :shib_tokens, :current_sign_in_at
  end
end