# This migration comes from mweb_events (originally 20131128152119)
class CreateMwebEventsEvents < ActiveRecord::Migration
  def change
    create_table :mweb_events_events do |t|
      t.string :name
      t.text :summary
      t.text :description
      t.string :social_networks
      t.references :owner, :polymorphic => true

      # for dates
      t.datetime :start_on
      t.datetime :end_on
      t.string :time_zone

      # for geocoding
      t.string :location
      t.string :address
      t.float :latitude
      t.float :longitude

      # for permalink
      t.string :permalink

      t.timestamps
    end

    add_index :mweb_events_events, :permalink
  end
end
