SITE_CONFIG = YAML.load_file(File.join(Rails.root, "config", "site_conf.yml"))

class AddSignatureToSite < ActiveRecord::Migration
  def self.up
    add_column :sites, :signature, :text, :default => SITE_CONFIG["signature"]
  end

  def self.down
    remove_column :sites, :signature
  end
end
