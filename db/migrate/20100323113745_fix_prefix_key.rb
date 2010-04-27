class FixPrefixKey < ActiveRecord::Migration
  def self.up
    change_column :profiles, :prefix_key, :string, :default=>""
    change_column :profiles, :user_id, :integer
    
    Profile.reset_column_information
    Profile.record_timestamps=false

    Profile.all.each do |p|
      p.update_attribute(:prefix_key,"") if p.prefix_key.nil?
    end
  end

  def self.down
   
  end
end
