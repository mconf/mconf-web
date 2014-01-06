# This migration comes from mweb_events (originally 20131202180907)
class AddLatitudeAndLongitudeToMwebEventsEvent < ActiveRecord::Migration
  def change
    add_column :mweb_events_events, :latitude, :float
    add_column :mweb_events_events, :longitude, :float
  end
end
