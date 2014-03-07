class EventPermalink < ActiveRecord::Migration
  def self.up
    add_column :events, :permalink, :string
    if defined? Event
      Event.record_timestamps =false
      Event.reset_column_information
      Event.all.each do |event|
        event.permalink = event.__send__(:create_permalink_for, [:name])
        event.save!
      end
    end
  end

  def self.down
    remove_column :events, :permalink
  end
end
