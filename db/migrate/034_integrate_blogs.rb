class IntegrateBlogs < ActiveRecord::Migration
  def self.up
    create_table :cms_texts do |t|
      t.string :type
      t.text :text
      t.timestamps
    end
    
    drop_table :articles
    drop_table :blogs
    drop_table :comments

    add_column :spaces, :created_at, :datetime
    add_column :spaces, :updated_at, :datetime
  end

  def self.down
    drop_table :cms_texts

    create_table :articles do |t|
      t.text :name
      t.text :body
      t.timestamps
    end

    create_table :blogs do |t|
      t.text :name
      t.timestamps
    end

    create_table :comments do |t|
      t.text :name
      t.text :body
      t.timestamps
    end

    remove_column :spaces, :created_at
    remove_column :spaces, :updated_at
  end
end
