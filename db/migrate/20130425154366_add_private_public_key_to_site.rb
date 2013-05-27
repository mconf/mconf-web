class AddPrivatePublicKeyToSite < ActiveRecord::Migration

  def self.up
    add_column :sites, :recaptcha_private_key, :string
    add_column :sites, :recaptcha_public_key, :string
  end

  def self.down
    add_column :sites, :recaptcha_private_key
    add_column :sites, :recaptcha_public_key
  end

end
