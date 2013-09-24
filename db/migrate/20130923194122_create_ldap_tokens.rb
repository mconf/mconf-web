class CreateLdapTokens < ActiveRecord::Migration
  def change
    create_table :ldap_tokens do |t|
      t.integer :user_id
      t.string :identifier
      t.text :data

      t.timestamps
    end
    add_index :ldap_tokens, :user_id, :unique => true
    add_index :ldap_tokens, :identifier, :unique => true
  end
end
