namespace :marte do
  desc "Clean the rooms for the past events"
  task(:cleanrooms => :environment) do
    Event.all(:conditions => ["end_date < ? and marte_room = 1", Date.yesterday]).each do |e|
      begin
        room = MarteRoom.find(e.id)
        room.destroy if room.present?
      rescue
        puts "Couldn't destroy MarteRoom for event #{ e.id }"
      end
      e.update_attribute(:marte_room, false) 
    end
  end
end

