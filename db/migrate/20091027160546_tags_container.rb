class TagsContainer < ActiveRecord::Migration
  def self.up
    add_column :tags, :container_id, :integer
    add_column :tags, :container_type, :string

    remove_index :tags, :name
    add_index :tags, [ :name, :container_id, :container_type ]

    drop_table :categories
    drop_table :categorizations
  end

  def self.down
    remove_column :tags, :container_id
    remove_column :tags, :container_type

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
  end
end
