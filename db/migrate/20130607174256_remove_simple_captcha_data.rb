class RemoveSimpleCaptchaData < ActiveRecord::Migration
  def self.up
    remove_index :simple_captcha_data, :name => "idx_key"
    drop_table :simple_captcha_data
  end

  def self.down
    create_table :simple_captcha_data do |t|
      t.string :key, :limit => 40
      t.string :value, :limit => 6
      t.timestamps
    end
    add_index :simple_captcha_data, :key, :name => "idx_key"
  end
end
