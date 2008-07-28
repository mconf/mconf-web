class CreateAttachments < ActiveRecord::Migration
  def self.up
    create_table :cms_attachment_fus do |t|
      t.string   :type
      t.integer  :size
      t.string   :content_type
      t.string   :filename
      t.integer  :height
      t.integer  :width
      t.integer  :parent_id
      t.string   :thumbnail
      t.integer  :db_file_id
      t.datetime :created_at
      t.datetime :updated_at
    
    end
   create_table :db_files , :force => true do |t|
     t.binary :data
   end
  end

  def self.down
    drop_table :cms_attachment_fus
    drop_table :db_files
  end
end
