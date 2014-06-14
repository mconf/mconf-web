class TagCount < ActiveRecord::Migration
  def self.up
    add_column :tags, :taggings_count, :integer, :default => 0

    if defined? Tag
      Tag.reset_column_information
      Tag.all.each do |t|
        Tag.update_counters t.id, :taggings_count => t.taggings.count
      end
    end
  end

  def self.down
    remove_column :tags, :taggings_count
  end
end
