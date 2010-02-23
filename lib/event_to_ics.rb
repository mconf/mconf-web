
module EventToIcs
  
 def to_ics
    agenda = self.agenda
    cal = Vpim::Icalendar.create2
    
    self.days.times do |i|
      
      entries = agenda.agenda_entries_for_day(i)
      
      entries.each do |entry|
        
        cal.add_event do |e|
          e.dtstart       entry.start_time
          e.dtend         entry.end_time
          e.summary       entry.title
          e.description   entry.description
          if entry.uid.nil? 
            e.uid "no_hay_uid"
          else 
            e.uid entry.uid
          end
          
          
          e.organizer do |o|
            o.cn = entry.speakers.to_s
            o.uri = "nil"
          end 
          
        end
        
      end
    end
    
    
    
    return cal.encode      
  end
  
end