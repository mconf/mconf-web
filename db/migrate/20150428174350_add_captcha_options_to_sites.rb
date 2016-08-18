class AddCaptchaOptionsToSites < ActiveRecord::Migration
  def change
    add_column :sites, :captcha_enabled, :boolean, default: false
    add_column :sites, :recaptcha_public_key, :string
    add_column :sites, :recaptcha_private_key, :string
  end
end
