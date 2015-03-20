class RemovePrivatePublicKeyToSite < ActiveRecord::Migration
  def self.up
    remove_column :sites, :recaptcha_private_key if column_exists? :sites, :recaptcha_private_key
    remove_column :sites, :recaptcha_public_key if column_exists? :sites, :recaptcha_public_key
    remove_column :sites, :use_recaptcha if column_exists? :sites, :use_recaptcha
  end

  def self.down
    add_column :sites, :recaptcha_private_key, :string unless column_exists? :sites, :recaptcha_private_key
    add_column :sites, :recaptcha_public_key, :string unless column_exists? :sites, :recaptcha_public_key
    add_column :sites, :use_recaptcha, :boolean, :default => false unless column_exists? :sites, :use_recaptcha
  end
end
