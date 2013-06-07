class AddPrivatePublicKeyToSite < ActiveRecord::Migration

  def self.up
    add_column :sites, :recaptcha_private_key, :string
    add_column :sites, :recaptcha_public_key, :string
    add_column :sites, :use_recaptcha, :boolean, :default => false
  end

  def self.down
    add_column :sites, :recaptcha_private_key
    add_column :sites, :recaptcha_public_key
    add_column :sites, :use_recaptcha
  end

end
