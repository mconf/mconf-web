#you need to add a file to /etc/cron.daily called cleanrooms.sh and give it execution rights (chmod +x /etc/cron.daily/cleanrooms.sh) and in that file call this rake (cd /sir_directory;rake marte:cleanrooms)

namespace :marte do
  desc "Clean the rooms for the past events"
  task(:cleanrooms => :environment) {
      @past_events = Event.find(:all, :conditions => ["end_date < ? and marte_room = 1", Date.yesterday])
      @past_events.select{|e| 
	begin
	  room = MarteRoom.find(e.id)
	  if room
		room.destroy
	  end
	  e.marte_room = 0
	rescue
	  #if the room does not exist, delete it from the event
	  e.marte_room = 0
	end
	e.save	
      }
  }
end

