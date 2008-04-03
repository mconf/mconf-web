class RolesSupport < ActiveRecord::Migration
  def self.up
    create_table :cms_roles do |t|
      t.string :name
      t.boolean :create_posts
      t.boolean :read_posts
      t.boolean :update_posts
      t.boolean :delete_posts
      t.boolean :create_performances
      t.boolean :read_performances
      t.boolean :update_performances
      t.boolean :delete_performances
    end

    create_table :cms_performances do |t|
      t.integer :agent_id
      t.string  :agent_type
      t.integer :role_id
      t.integer :container_id
      t.string  :container_type
    end
  end

  def self.down
    drop_table :cms_roles
    drop_table :cms_performances
  end
end
