class RenameMwebEventsPolymorphicRelations < ActiveRecord::Migration
  def up
    puts "Migrating polymorphic types from 'MwebEvents::Events to Events"
    RecentActivity.where(trackable_type: 'MwebEvents::Event').update_all(trackable_type: 'Event')
    RecentActivity.where(trackable_type: 'MwebEvents::Participant').update_all(trackable_type: 'Participant')
    Permission.where(subject_type: 'MwebEvents::Event').update_all(subject_type: 'Event')
    Invitation.where(target_type: 'MwebEvents::Event').update_all(target_type: 'Event')
  end

  def down
    puts "Migrating polymorphic types back from 'Events to MwebEvents::Events"
    RecentActivity.where(trackable_type: 'Event').update_all(trackable_type: 'MwebEvents::Event')
    RecentActivity.where(trackable_type: 'Participant').update_all(trackable_type: 'MwebEvents::Participant')
    Permission.where(subject_type: 'Event').update_all(subject_type: 'MwebEvents::Event')
    Invitation.where(target_type: 'Event').update_all(target_type: 'MwebEvents::Event')
  end
end
