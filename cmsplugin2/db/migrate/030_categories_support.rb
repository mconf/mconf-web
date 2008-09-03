class CategoriesSupport < ActiveRecord::Migration
  def self.up
    create_table :cms_categories, :force => true do |t|
      t.string   :name
      t.text     :description
      t.integer  :container_id
      t.string   :container_type
      t.integer  :parent_id
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :cms_categorizations, :force => true do |t|
      t.integer :category_id
      t.integer :post_id
    end
  end

  def self.down
    drop_table :cms_categories
    drop_table :cms_categorizations
  end
end
