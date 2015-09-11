class RenameMwebEventsPolymorphicRelations < ActiveRecord::Migration
  def up
    puts "****** Migrating polymorphic types from 'MwebEvents::Events to Events"
    RecentActivity.where(trackable_type: 'MwebEvents::Event').each do |act|
      act.update_attributes(trackable_type: 'Event')
    end

    RecentActivity.where(trackable_type: 'MwebEvents::Participant').each do |act|
      act.update_attributes(trackable_type: 'Participant')
    end

    Permission.where(subject_type: 'MwebEvents::Event').each do |p|
      p.update_attributes(subject_type: 'Event')
    end

    Invitation.where(target_type: 'MwebEvents::Event').each do |inv|
      inv.update_attributes(target_type: 'Event')
    end
  end

  def down
    puts "****** Migrating polymorphic types back from 'Events to MwebEvents::Events"

    RecentActivity.where(trackable_type: 'Event').each do |act|
      act.update_attributes(trackable_type: 'MwebEvents::Event')
    end

    RecentActivity.where(trackable_type: 'Participant').each do |act|
      act.update_attributes(trackable_type: 'MwebEvents::Participant')
    end

    Permission.where(subject_type: 'Event').each do |p|
      p.update_attributes(subject_type: 'MwebEvents::Event')
    end

    Invitation.where(target_type: 'Event').each do |inv|
      inv.update_attributes(target_type: 'MwebEvents::Event')
    end
  end
end
