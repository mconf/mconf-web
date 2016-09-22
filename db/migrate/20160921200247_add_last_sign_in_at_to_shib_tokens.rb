class AddLastSignInAtToShibTokens < ActiveRecord::Migration
  def up
    add_column :shib_tokens, :last_sign_in_at, :datetime
  end
  def down
    remove_column :shib_tokens, :last_sign_in_at
  end
end
