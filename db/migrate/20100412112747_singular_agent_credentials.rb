class SingularAgentCredentials < ActiveRecord::Migration
  def self.up
    add_column :singular_agents, :crypted_password, :string, :limit => 40
    add_column :singular_agents, :salt, :string, :limit => 40
  end

  def self.down
    remove_column :singular_agents, :crypted_password
    remove_column :singular_agents, :salt
  end
end
