module EventsHelper
  
 
  def get_user_state(event,event_user)
      event.participants.select {|p| p.user == event_user}.first.attend
    end
    def get_participant(event,event_user)
      event.participants.select {|p| p.user == event_user}.first
    end
    
    
  #method to know if this event has been accomplished already
    def already_accomplished(event)
      for datetime in event.event_datetimes
        if datetime.start_date>Time.now
          return false
        end
      end
      return true
    end  
   #method to know if there are events at this hour between the events in the array @events
    #that are all of the same day
    #retuns an array of events at this time or nil if no event found
    def events_at_this_time(events, date, hour)
      array_events = []
      for event in events
        for datetime in event.event_datetimes
          #logger.debug("start_date.day: " + datetime.start_date.day.to_s + " end_date.day: " + datetime.end_date.day.to_s)
          #logger.debug("start_date.hour: " + datetime.start_date.hour.to_s)
          if datetime.start_date.day >= date.day && datetime.end_date.day <= (date.day) && datetime.start_date.hour==hour
            array_events << event
          end
        end
      end
      if array_events.size>0
        return array_events
      else
        return nil
      end
    end
    
    
    #method to know if there are events at this hour between the events in the array @events
    #that are all of the same day
    #retuns an array of events at this time or nil if no event found
    def event_at_this_time(events, date, hour)
      for event in events
        for datetime in event.event_datetimes
          if datetime.start_date.day == date.day && datetime.start_date.hour==hour
            logger.debug("El evento a esta hora es " + event.name)
            return event
          end
          #breakpoint()
          if datetime.start_date < Time.parse(date.to_s) && datetime.end_date.day==date.day && datetime.end_date.hour >= hour
            logger.debug("Event comes from past and finishes today, it is called " + event.name)
            return event
          end
          #comes from past and don't finish today, duration = 24
          if datetime.start_date < Time.parse(date.to_s) && datetime.end_date > Time.parse(date.to_s)
            logger.debug("Event comes from past and don't finish today, duration = 24, it is called " + event.name)
            return event
          end
        end
      end
      return nil
    end
    
     #method to know if there are events at this quarter of an hour between the events in the array @events
    #that are all of the same day
    #retuns the duration (in quarters of an hour) of the event at this time or nil if no event found
    def event_duration_at_this_time(events, date, hour)    
      #logger.debug("event_duration_at_this_time para la hora " + hour.to_s)
      #logger.debug("events.size " + events.size.to_s)
      if events==nil || events.size==0
        return nil
      end
      for event in events
        for datetime in event.event_datetimes
          #logger.debug("comprobando datetime.start_date.day " + datetime.start_date.day.to_s)
          #event starts today
          if datetime.start_date.day == date.day && datetime.start_date.hour==hour
            duration = (datetime.end_date - datetime.start_date)/3600
            duration = duration.ceil    #round to the integer inmediately bigger than it
            #breakpoint()
            if duration >= (24-hour)
              duration = 24 - hour
              return duration
            else
              duration = datetime.end_date.hour - datetime.start_date.hour
              #logger.debug("Duration es " + duration.to_s)
              return duration+1
            end            
          end
          #event comes from past and finishes today
          #breakpoint()
          if datetime.start_date < Time.parse(date.to_s) && datetime.end_date.day==date.day && datetime.end_date.hour >= hour
            logger.debug("event comes from past and finishes today")
            duration = datetime.end_date.hour + 1
            return duration
          end
          #comes from past and don't finish today, duration = 24
          if datetime.start_date < Time.parse(date.to_s) && datetime.end_date > Time.parse(date.to_s) && datetime.end_date.day!=date.day
            logger.debug("Event comes from past and don't finish today, duration = 24")
            duration = 24
            return duration
          end
          
        end
      end
      return nil    
    end
    
     #method to format array of events of one day returning an array of arrays
    #each array has events of the day that do not overlap
    #each array will be displayed in a mini table
    def format_array_events(array_events)
      logger.debug("FORMAT ARRAY de tamaño de entrada " + array_events.size.to_s)
      if(array_events.size==0)
        return array_events
      end    
      result_array = []
      #the first event do not overlap with other
      result_array[0] = []
      event_temp = array_events.pop
      logger.debug("meto en 0 el evento " + event_temp.name)
      result_array[0] << event_temp    
      already_in = false
      #for each event i do the algorithm
      for event in array_events
        logger.debug("entra para evento " + event.name)
        logger.debug("already_in es " + already_in.to_s)
        #for each array to allocate i test if it can be good for the event
        for index in 0..(result_array.size-1)
          if !event.overlaps_with_event_in_array(result_array[index])
            logger.debug("meto el evento en el array de index " + index.to_s)
            result_array[index] << event
            already_in = true
            break
          end
        end
        #if not allocated i do a new array
        if !already_in
          logger.debug("meto el evento en un array nuevo ")
          result_array[index+1] = []
          result_array[index+1] << event        
        end
        already_in = false #the next one is not saved yet
      end
      logger.debug("FORMAT ARRAY de tamaño " + result_array.size.to_s)
      return result_array
    end
    
    
    def shared_embed_streaming(event)
      result = '<div id="globalplaza_embed" style="width:645px;"><strong style="display:block;padding:12px 0 4px;">'
      result += link_to(event.title,space_event_url(event.space, event))   
      result +='</strong><div style="padding:3px 3px 0px 3px;background:#244974">'
      result += event.streaming(640, 480, 'flash')
      result += '<div style="padding:0 6px 0px 6px;text-align:right;"><a style="text-decoration:none;outline:none;font-weight:bold;color:#fff" href="http://www.globalplaza.org"><img src="http://www.globalplaza.org/images/bola_global_peque.png" style="margin-bottom:-3px"/> Global Plaza</a></div>'
      result += '</div></div>'
    
      return result      
    end
  
    #method to generate a hash to represent the entries and the status of each entry
    #this hash is like this example: var entries = {123:"recording", 234: "recorded", 33: "published", 454: "init"}
    def generate_entries_javascript_array(event)
      output = "var entries = {"
      event.agenda.agenda_entries.each do |entry| 
        output += entry.id.to_s + ": \"" + entry.session_status + "\","
      end
      output.chop!
      output += "}"
    end
 
end
