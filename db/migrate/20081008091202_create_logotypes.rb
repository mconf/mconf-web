class CreateLogotypes < ActiveRecord::Migration
  def self.up
    create_table :logotypes do |t|
      t.string   :type
      t.integer  :size
      t.string   :content_type
      t.string   :filename
      t.integer  :height
      t.integer  :width
      t.integer  :parent_id
      t.string   :thumbnail
      t.integer  :db_file_id
      t.string   :logotypable_type
      t.integer  :logotypable_id
      t.datetime :created_at
      t.datetime :updated_at

    end
  end

  def self.down
    drop_table :logotypes
  end
end
