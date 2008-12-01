class PoweredCategories < ActiveRecord::Migration
  ActiveRecord::Base.record_timestamps = false

  def self.up
    rename_column :categories, :container_id, :domain_id
    rename_column :categories, :container_type, :domain_type
    rename_column :categorizations, :entry_id, :categorizable_id
    add_column :categorizations, :categorizable_type, :string

    Categorization.all.each do |c|
      c.update_attribute :categorizable, Entry.find(c.categorizable_id).content
    end
    
  end

  def self.down
    Categorization.all.each do |c|
      c.update_attribute :categorizable_id, c.categorizable.entry
    end

    remove_column :categorizations, :categorizable_type
    rename_column :categorizations, :categorizable_id, :entry_id
    rename_column :categories, :domain_id, :container_id
    rename_column :categories, :domain_type, :container_type
  end
end
