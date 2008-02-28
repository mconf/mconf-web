class EventDatetime < ActiveRecord::Base
    belongs_to :event
    
    MAXIMUM_LENGTH_IN_HOURS = 10 #hours of maximum length of the event warning will be displayed 
                                   #if the event duration is above this integer
    MINIMUM_LENGTH_IN_MINUTES = 30 #minutes of minimum length of the event, warning will be displayed 
                                   #if the event duration is bellow this integer
  
    
    #returns true if there is a datetime bellow the minimun
    def self.datetime_min_length(array_datetimes)       
       for datetime in array_datetimes  
          if (datetime.end_date-datetime.start_date)<MINIMUM_LENGTH_IN_MINUTES*60
              #errors.add(:datetimes, "the " +get_ordinal(indice) + " date entry is incorrect," +
              #         "the interval between start and end is smaller than "+MINIMUM_LENGTH_IN_MINUTES.to_s+" minutes") 
              return true
          end
       end       
       return false   
    end
    
    
   #returns true if there is a datetime above the maximun
   def self.datetime_max_length(array_datetimes)
     for datetime in array_datetimes
          if (datetime.end_date-datetime.start_date)>MAXIMUM_LENGTH_IN_HOURS*3600
            #errors.add(:datetimes, "the " +get_ordinal(indice) + " date entry is incorrect," +
            #         "the interval between start and end is bigger than "+MAXIMUM_LENGTH_IN_HOURS.to_s+" hours") 
            return true
          end
       end
       return false
    end
   
    
    #method that returns the array to highlight the dates with event
    #the format of the array is: 
    #var SPECIAL_DAYS = {
    #    2007:{  0 : [ 13, 24 ],		// special days in January
    #            2 : [ 1, 6, 8, 12, 18 ],	// special days in March
    #            8 : [ 21, 11 ]		// special days in September
    #          },
    #    2008:{  0 : [ 12, 23 ],		// special days in January
    #            2 : [ 2, 6, 8, 12, 18 ],	// special days in March
    #            8 : [ 21, 11 ]		// special days in September
    #          }
    #          }; 
    #it is called by: <%=EventDatetime.array_calendar%>
    def self.array_calendar
        year = Date.today.year
        #year = year - 1  #the first year to show is the last year
        
        array = "var SPECIAL_DAYS = { \n"
        hay_coma = false
        #I return the array with the dates for the last year and the next four years
        5.times do
          if has_events_for_year(year) 
            array = array + " " + year.to_s + ": " + array_for_year(year)
            hay_coma = true
          end
          year = year + 1        
        end      
        #I have to remove the last "," in order to be javascript valid        
        if hay_coma
        	array = array[0..-4]  + " \n"
        end
        array = array + "};"
        return array
    end
    
    
    private
    
    #method to know if the year has any event
    def self.has_events_for_year(year)
      event_datetimes = EventDatetime.find(:all, :conditions=> ["start_date >= ? AND end_date <= ?", year.to_s+"-01-01 00:00:00" , year.to_s+"-12-31 23:59:59"])
      if event_datetimes.length > 0        
        return true
      else 
        return false   
      end 
    end
    
    
    #method to know if the month (from 0 [january] to 11[december]) of the year has any event
    def self.has_events_for_month(year, month)
      event_datetimes = EventDatetime.find(:all, :conditions=> ["start_date >= ? AND end_date <= ?", year.to_s+"-" + (month+1).to_s+ "-01 00:00:00" , year.to_s+"-" + (month+1).to_s+ "-31 23:59:59"])
      if event_datetimes.length > 0         
        return true
      else 
        return false   
      end 
    end
    
    
    #return the array with the events for the year
    def self.array_for_year(year)
      array2 = "{"
      month = 0   #month goes from 0 (january) to 11 (december)
      12.times do
        if has_events_for_month(year, month)        
            array2 = array2 + " " + month.to_s + " : " + array_for_month(year, month)           
          end
          month = month + 1      
      end      
      #I have to remove the last "," in order to be javascript valid      
      array2 = array2[0..-2]       
      array2 = array2 + "}, \n"      
      return array2                   
    end
    
    
    #return the array with the events for the month (from 0 [january] to 11[december])
    def self.array_for_month(year, month)
      event_datetimes = EventDatetime.find(:all, :conditions=> ["start_date >= ? AND end_date <= ?", year.to_s+"-" + (month+1).to_s+ "-01 00:00:00" , year.to_s+"-" + (month+1).to_s+ "-31 23:59:59"])
      array = "["
      for datetime in event_datetimes
        array = array + datetime.start_date.day.to_s + ","
      end
      #I have to remove the last "," in order to be javascript valid      
      array = array[0..-2]       
      array = array + "],"
      return array
    end
    
    
    #def self.format_time(the_time)
    #  string_time = ""
    #  string_time += the_time.month.to_s + " " + the_time.day.to_s + " "
    #  string_time += the_time.hour.to_s + ":" + the_time.min.to_s
    #  return string_time
    #end
    
    
    #def <=>(other)
    #  logger.debug("SE LLAMA AL OPERADOR")
    #  return 1
    #end
    #
end
