class CreateSources < ActiveRecord::Migration
  def self.up
    create_table :sources do |t|
      t.references :uri
      t.string :content_type
      t.string :target
      t.references :container, :polymorphic => true
      t.datetime :imported_at

      t.timestamps
    end

    add_column :news, :guid, :string
    add_column :posts, :guid, :string

    drop_table :readers
  end

  def self.down
    drop_table :sources
    remove_column :news, :guid
    remove_column :posts, :guid

    create_table :readers do |t|
      t.string   :url
      t.integer  :space_id
      t.datetime :last_updated
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
