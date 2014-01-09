# This migration comes from mweb_events (originally 20140108172141)
class AddTimeZoneToMwebEventsEvent < ActiveRecord::Migration
  def change
    add_column :mweb_events_events, :time_zone, :string
  end
end
