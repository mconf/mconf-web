class AddShibEnvVariablesToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :shib_env_variables, :text
  end

  def self.down
    remove_column :sites, :shib_env_variables
  end
end
