# This migration comes from mweb_events (originally 20131212170412)
class CreateMwebEventsParticipants < ActiveRecord::Migration
  def change
    create_table :mweb_events_participants do |t|
      t.references :owner, :polymorphic => true
      t.references :event
      t.string :email

      t.timestamps
    end
  end
end
