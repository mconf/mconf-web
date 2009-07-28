class AddEventIdToAdmissions < ActiveRecord::Migration
  def self.up
    add_column :admissions, :event_id, :integer
  end

  def self.down
    remove_column :admissions, :event_id
  end
end
