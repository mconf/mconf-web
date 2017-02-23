class CreateCertificateTokens < ActiveRecord::Migration
  def up
    create_table :certificate_tokens do |t|
      t.string     :identifier
      t.integer    :user_id
      t.text       :public_key
      t.boolean    :new_account, default: false
      t.datetime   :current_sign_in_at
      t.timestamps
    end

    add_index :certificate_tokens, :user_id, unique: true
    add_index :certificate_tokens, :identifier, unique: true
  end

  def down
    drop_table :certificate_tokens
  end
end
