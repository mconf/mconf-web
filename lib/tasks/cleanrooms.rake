#you need to add a file to /etc/cron.daily called cleanrooms.sh and give it execution rights (chmod +x /etc/cron.daily/cleanrooms.sh) and in that file call this rake (cd /sir_directory;rake rooms:clean)

namespace :rooms do
  desc "Clean the rooms for the past events"
  task(:clean => :environment) {
      @past_events = Event.find(:all, :conditions => ["end_date < ? and marte_room = 1", Date.yesterday])
      @past_events.select{|e| 
	MarteRoom.find(e.id).destroy
      }
  }
end

