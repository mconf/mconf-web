# A migration to set needed tables for CMS support

class CmsSetup < ActiveRecord::Migration
  def self.up
    create_table :cms_posts do |t|
      t.string   :title
      t.text     :description
      t.timestamps
      t.integer  :container_id
      t.string   :container_type
      t.integer  :agent_id
      t.string   :agent_type
      t.integer  :content_id
      t.string   :content_type
      t.integer  :parent_id
      t.string   :parent_type
      t.boolean  :public_read
      t.boolean  :public_write
    end

    create_table :cms_uris do |t|
      t.string :uri
    end
    add_index :cms_uris, :uri

    create_table :open_id_ownings do |t|
      t.integer :agent_id
      t.string  :agent_type
      t.integer :uri_id
    end

    create_table :open_id_associations, :force => true do |t|
      t.binary  :server_url
      t.string  :handle
      t.binary  :secret
      t.integer :issued
      t.integer :lifetime
      t.string  :assoc_type
    end

    create_table :open_id_nonces, :force => true do |t|
      t.string  :server_url, :null => false
      t.integer :timestamp,  :null => false
      t.string  :salt,       :null => false
    end
  end

  def self.down
    drop_table :cms_posts
    drop_table :cms_uris
    drop_table :open_id_associations
    drop_table :open_id_nonces
  end
end
