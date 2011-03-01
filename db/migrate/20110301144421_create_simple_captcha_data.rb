class CreateSimpleCaptchaData < ActiveRecord::Migration
  def self.up
    # drop the old table (see init.rb)
    drop_table :simple_captcha_data

    create_table :simple_captcha_data do |t|
      t.string :key, :limit => 40
      t.string :value, :limit => 6
      t.timestamps
    end
    
    add_index :simple_captcha_data, :key, :name => "idx_key"
  end

  def self.down
    drop_table :simple_captcha_data

    # create the old table (see init.rb)
    create_table "simple_captcha_data", :force => true do |t|
      t.string   "key",        :limit => 40
      t.string   "value",      :limit => 6
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
