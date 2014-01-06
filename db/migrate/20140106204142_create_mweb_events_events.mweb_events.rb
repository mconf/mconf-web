# This migration comes from mweb_events (originally 20131128152119)
class CreateMwebEventsEvents < ActiveRecord::Migration
  def change
    create_table :mweb_events_events do |t|
      t.string :name
      t.date :start_on
      t.date :end_on
      t.string :location
      t.string :address
      t.text :description
      t.references :owner, :polymorphic => true

      t.timestamps
    end
  end
end
