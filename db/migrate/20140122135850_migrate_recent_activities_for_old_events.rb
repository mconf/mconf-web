class MigrateRecentActivitiesForOldEvents < ActiveRecord::Migration
  def up
    PublicActivity::Activity.where(:trackable_type => "Event", :key => "event.create")
      .update_all(:trackable_type => "MwebEvents::Event", :key => "mweb_events_event.create")
    PublicActivity::Activity.where(:trackable_type => "Event", :key => "event.update")
      .update_all(:trackable_type => "MwebEvents::Event", :key => "mweb_events_event.update")
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
