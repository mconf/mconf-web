# position of each field in the array of an Event
EVENT_ID = 0
EVENT_NAME = 1
EVENT_DESCRIPTION = 2
EVENT_PLACE = 3
EVENT_START_DATE = 4
EVENT_END_DATE = 5
EVENT_PARENT_ID = 6
EVENT_CREATED_AT = 7
EVENT_UPDATED_AT = 8
EVENT_SPACE_ID = 9
EVENT_AUTHOR_ID = 10
EVENT_AUTHOR_TYPE = 11
EVENT_SPAM = 12
EVENT_NOTES = 13
EVENT_LOCATION = 14
EVENT_PERMALINK = 15
EVENT_OTHER = 16

# position of each field in the array of a Participant
PART_ID = 0
PART_EMAIL = 1
PART_USER_ID = 2
PART_EVENT_ID = 3
PART_CREATED_AT = 4
PART_UPDATED_AT = 5
PART_ATTEND = 6

class MigrateEventsToMwebEvents < ActiveRecord::Migration
  def up
    sql = "SELECT * FROM events"
    events = ActiveRecord::Base.connection.execute(sql)
    events.each do |event|
      puts "Migrating the event: #{event}"
      new_event = MwebEvents::Event.new
      new_event.location = event[EVENT_LOCATION]
      new_event.start_on = event[EVENT_START_DATE]
      new_event.end_on = event[EVENT_END_DATE]
      new_event.description = event[EVENT_DESCRIPTION]
      new_event.name = event[EVENT_NAME]
      if event[EVENT_SPACE_ID]
        space = Space.find_by_id(event[EVENT_SPACE_ID])
        if space
          new_event.owner_id = space.id
          new_event.owner_type = 'Space'
        end
      else
        new_event.owner_id = event[EVENT_AUTHOR_ID]
        new_event.owner_type = event[EVENT_AUTHOR_TYPE]
        unless event[EVENT_AUTHOR_TYPE] == "User"
          puts "*** WARNING: author type is not 'User', new event might have a wrong owner"
        end
      end
      new_event.description = ActionView::Base.full_sanitizer.sanitize(event[EVENT_DESCRIPTION])
      new_event.summary = new_event.description[0..139]
      new_event.permalink = event[EVENT_PERMALINK]
      new_event.time_zone = Site.current.timezone
      new_event.created_at = event[EVENT_CREATED_AT]
      new_event.updated_at = event[EVENT_UPDATED_AT]
      if new_event.save
        sql = "SELECT * FROM participants WHERE event_id = #{event[EVENT_ID]}"
        participants = ActiveRecord::Base.connection.execute(sql)
        participants.each do |participant|
          if participant[PART_ATTEND] == 1
            new_participant = MwebEvents::Participant.new
            new_participant.owner = User.find_by_id(participant[PART_USER_ID])
            new_participant.event_id = new_event.id
            new_participant.email = participant[PART_EMAIL]
            unless new_participant.save
              puts "Could not migrate the participant: #{participant}"
            else
              puts "Successfully migrated the participant: #{participant[PART_EMAIL]}"
            end
          else
            puts "Participant was not attending, won't be migrated: #{participant[PART_EMAIL]}"
          end
        end
        puts "Successfully migrated the event: #{event[EVENT_NAME]}"
      else
        puts "Could not migrate the event: #{event}"
      end
    end
  end

  def down
    throw ActiveRecord::IrreversibleMigration
  end
end
