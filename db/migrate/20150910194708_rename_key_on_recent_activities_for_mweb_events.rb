class RenameKeyOnRecentActivitiesForMwebEvents < ActiveRecord::Migration
  def up
    RecentActivity.where(key: 'mweb_events_event.create').update_all(key: 'event.create')
    RecentActivity.where(key: 'mweb_events_event.update').update_all(key: 'event.update')
    RecentActivity.where(key: 'mweb_events_participant.create').update_all(key: 'participant.create')
  end

  def down
    RecentActivity.where(key: 'event.create').update_all(key: 'mweb_events_event.create')
    RecentActivity.where(key: 'event.update').update_all(key: 'mweb_events_event.update')
    RecentActivity.where(key: 'participant.create').update_all(key: 'mweb_events_participant.create')
  end
end
