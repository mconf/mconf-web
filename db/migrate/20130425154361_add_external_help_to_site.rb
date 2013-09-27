class AddExternalHelpToSite < ActiveRecord::Migration

  def self.up
    add_column :sites, :external_help, :string
  end

  def self.down
    remove_column :sites, :external_help
  end

end
