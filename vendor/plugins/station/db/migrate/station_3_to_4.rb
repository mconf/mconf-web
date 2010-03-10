class Station3To4 < ActiveRecord::Migration
  def self.up
    add_column :tags, :container_id, :integer
    add_column :tags, :container_type, :string
    add_column :tags, :taggings_count, :integer, :default => 0

    remove_index :tags, :name
    add_index :tags, [ :name, :container_id, :container_type ]

    Tag.reset_column_information
    Tag.all.each do |t|
      Tag.update_counters t.id, :taggings_count => t.taggings.count
    end

    drop_table :categories
    drop_table :categorizations

    # local column should be in OpenID ownings, not in OpenID trusts
    remove_column :open_id_trusts, :local
    add_column :open_id_ownings, :local, :boolean, :default => false
  end

  def self.down
    remove_column :tags, :container_id
    remove_column :tags, :container_type
    remove_column :tags, :taggings_count

    remove_index :tags, :column => [ :name, :container_id, :container_type ]
    add_index :tags, :name

    create_table :categories do |t|
      t.string   :name
      t.text     :description
      t.integer  :domain_id
      t.string   :domain_type
      t.integer  :parent_id
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :categorizations do |t|
      t.integer :category_id
      t.integer :categorizable_id
      t.string  :categorizable_type
    end

    # local column should be in OpenID ownings, not in OpenID trusts
    add_column :open_id_trusts, :local, :boolean, :default => false
    remove_column :open_id_ownings, :local
  end
end
