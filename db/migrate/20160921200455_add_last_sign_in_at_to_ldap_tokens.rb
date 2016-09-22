class AddLastSignInAtToLdapTokens < ActiveRecord::Migration
  def up
    add_column :ldap_tokens, :last_sign_in_at, :datetime
  end
  def down
    remove_column :ldap_tokens, :last_sign_in_at
  end
end
