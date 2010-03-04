class LocalOpenidOwnings < ActiveRecord::Migration
  def self.up
    # local column should be in OpenID ownings, not in OpenID trusts
    remove_column :open_id_trusts, :local
    add_column :open_id_ownings, :local, :boolean, :default => false
  end

  def self.down
    add_column :open_id_trusts, :local, :boolean, :default => false
    remove_column :open_id_ownings, :local
  end
end
