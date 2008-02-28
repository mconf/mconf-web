class CreateDatetimes < ActiveRecord::Migration
  def self.up
    create_table :event_datetimes do |t|
      t.column :event_id, :integer, :null=>false
      t.column :start_date, :timestamp, :null=>false
      t.column :end_date, :timestamp, :null=>false
      t.column :at_job, :integer, :null=>true
    end
  end

  def self.down
    drop_table :event_datetimes
  end
end
