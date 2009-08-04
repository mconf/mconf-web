class DeleteEntriesTable < ActiveRecord::Migration
  def self.up
    add_column :posts, :space_id, :integer
    add_column :posts, :author_id, :integer
    add_column :posts, :author_type, :string
    add_column :posts, :parent_id, :integer
    add_column :events, :space_id, :integer
    add_column :events, :author_id, :integer
    add_column :events, :author_type, :string
    add_column :attachments, :post_id, :integer

    drop_table :entries
  end

  def self.down
    create_table "entries", :force => true do |t|
      t.string   "title"
      t.text     "description"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "container_id"
      t.string   "container_type"
      t.integer  "agent_id"
      t.string   "agent_type"
      t.integer  "content_id"
      t.string   "content_type"
      t.integer  "parent_id"
      t.string   "parent_type"
      t.boolean  "public_read"
      t.boolean  "public_write"
    end

#    remove_column :posts, :space_id
#    remove_column :posts, :author_id
#    remove_column :posts, :author_type
#    remove_column :posts, :parent_id
#    remove_column :events, :space_id
    remove_column :events, :author_id
    remove_column :events, :author_type
    remove_column :attachments, :post_id
  end
end
