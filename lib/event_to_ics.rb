 
module EventToIcs
  
 def to_ics
    agenda = self.agenda
    cal = Vpim::Icalendar.create
    
    self.days.times do |i|
      
      entries = agenda.contents_for_day(i+1)

      entries.each do |entry|
        
        cal.add_event do |e|
#debugger
          if entry.start_time.nil?
            e.dtstart       "none"
          else
            e.dtstart       entry.start_time
          end
#debugger          
          if entry.end_time.nil?
            e.dtend         "none"
          else
            e.dtend         entry.end_time  
          end
#debugger          
          if entry.title.nil? 
            e.summary   "none"
          else 
            e.summary       entry.title
          end         
#debugger          
          if entry.description.nil? 
            e.description   "none"
          else 
            e.description   entry.description
          end
#debugger         
          if entry.uid.nil? 
            e.uid "no_hay_uid"
          else 
            e.uid entry.uid
          end
#debugger          
          
          e.organizer do |o|
            if entry.speakers.nil?
              o.cn = "none"
            else
              o.cn = entry.speakers.to_s  
            end
            
            o.uri = "none"
          end 
#debugger          
        end
      end
    end
    
    return cal.encode      
  end
  
end
