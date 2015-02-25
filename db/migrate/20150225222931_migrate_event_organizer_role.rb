class MigrateEventOrganizerRole < ActiveRecord::Migration
  def up
    role = Role.where(stage_type: 'Event', name: 'Organizer').first
    role.try(:update_attribute, :stage_type, 'MwebEvents::Event')
  end

  def down
    role = Role.where(stage_type: 'MwebEvents::Event', name: 'Organizer').first
    role.try(:update_attribute, :stage_type, 'Event')
  end
end
