require 'ferret'

class Event < ActiveRecord::Base
  acts_as_ferret :fields => {  
  :name=> {:store => :yes} ,
  :description=> {:store => :yes} , 
  :tag_list=> {:store => :yes},
  :start_dates => {:store => :yes} }
   has_many :event_datetimes,
             :dependent => :destroy  
    has_many :participants, 
             :dependent => :destroy 
    has_many :machines, :through => :participants
    acts_as_content
    alias_attribute :title, :name
    validates_presence_of :name, 
                          :message => "must be specified"
   
   
   
   
   #callbacks
    #After destroy an event, we must destroy the xedl file and the at_jobs referenced to that even 
  def after_destroy
    
     delete_file(@file_to_delete)
     delete_at_jobs(@at_jobs_array)
   end
   #After create an event we must create his xedl file and his at_jobs
  def after_create
        create_and_save_xedl
        create_at_jobs
        logger.debug("El after create ha funcionado")
    
   end
 #After we update an event, me must delete de old at_jobs and the old xedl file, and then 
 #we must create againa the news one 
  def after_update
          
    delete_at_jobs(@at_jobs_array)
    create_at_jobs
     delete_file(@file_to_delete)
    create_and_save_xedl  
  end
  
  #Before we destroy an event we must look for two files: the xedl file and the at_jobs
  #because if we destroy the event we couldn't find the files'
  def before_destroy
    
    save_old_values
  end
  
   #the same than before_destroy
   def save_old_values
     
      @at_jobs_array = get_at_jobs
     @file_to_delete = get_xedl_filename
   end
   
   
  #array of types of service
  SERVICE_TYPES = [
   ["TeleMeeting", "meeting.act"],
   ["TeleClass", "class.act"],
   ["TeleConference", "conference.act"]].freeze  #makes this array constant
 
  #para hacer <%= select("event", "service", Event::SERVICE_TYPES)%>
  SERVICE_QUALITIES = [
    ["512K","512K"],
    ["1M","1M"],
    ["2M","2M"],
    ["5M","5M"]].freeze
   
    
    
  #Ein... falta test
  def self.service_qualities
      begin
        if File.exist?("act.qualities")
          string_file = File.read("act.qualities")
          service_qualities_good = []
          string_file = string_file.split
          for i in 0..(string_file.size-1)
              service_qualities_good << [string_file[i],string_file[i]]
          end
          return service_qualities_good
        else
          return SERVICE_QUALITIES
        end        
      rescue
        logger.debug("ERROR Error en service_qualities")
        return SERVICE_QUALITIES
      end
    end
  
    
  #method that returns an array with the participants in common between this event an the
  #participants appearing in the array_numbers
  def contains_participants(array_numbers)
     array_participants_this_event = []
     for participant in participants
       array_participants_this_event << participant.machine_id 
     end
     coincidences = []
     for i in array_numbers
       if array_participants_this_event.index(i)!=nil
         coincidences << i
       end       
     end
     return coincidences
  end
    
    
    #method to know if this event uses a participant return true or false 
    def uses_participant(machine_id)
      logger.debug("Voy a ver si usa la machine " + machine_id.to_s)
      logger.debug("partic " + participants.to_s)
      if machine_id == 0 || machine_id == "0"
        return true   #participant 0 is all
      end
      for participant in participants
        logger.debug("participant id " + participant.machine_id.to_s)
        if participant.machine_id.to_s==machine_id.to_s
          return true
        end
      end
      return false
    end
    
    
    #method to validate datetimes and participants
    def validate
      validate_participants(participants)
      validate_datetime(event_datetimes)
    end
    
        
    #returns the content for the submenu
  #the content is the description and the machines that this event uses
  def get_submenu
      content = ""
      content += description
      content += " -- Resources:"
      content += get_participants
      return content      
  end
  
    
    def get_participants
      participant_list = ""
      i=0
      for parti in participants
       if i==0
        participant_list +=  Machine.find(parti.machine_id).name
      else
         participant_list += " "+ Machine.find(parti.machine_id).name
       end
        i += 1
      end
      return participant_list
    end
    
    
    #this method returns an array with the url/s for the session
    def get_urls
      url = []
      i = 0
      for participant in participants
        url[i] = "isabel://" + Machine.find(participant.machine_id).nickname
        i += 1
      end
      return url
    end
    
    
    def get_participants_description
      desc = []
      i = 0
      for participant in participants
        desc[i] = participant.description
        i += 1
      end
      return desc
    end
    
    
    def get_machine_names
      machine_names = []
      i=0
      for participant in participants
        machine_names[i] = Machine.find(participant.machine_id).name
        i += 1
      end
      return machine_names
    end
    
    
    def get_xedl_filename
      nombre_fichero = "xedls/" + name + "-" + event_datetimes[0].start_date.day.to_s 
      nombre_fichero = nombre_fichero + "-" + event_datetimes[0].start_date.month.to_s 
      nombre_fichero = nombre_fichero + "-" + event_datetimes[0].start_date.year.to_s 
      nombre_fichero = nombre_fichero + "-at-" + event_datetimes[0].start_date.hour.to_s 
      nombre_fichero = nombre_fichero + "-" + event_datetimes[0].start_date.min.to_s + ".xedl"
      return nombre_fichero
    end
    
    
    def overlaps_with_event_in_array(array_events)
     for event in array_events
       for datetime in event_datetimes
         if overlaps_with_another?(datetime.start_date, datetime.end_date, 0, event.event_datetimes, true)
           return true
         end
       end
     end
     return false
  end
    
    
    def has_any_session_in_the_past
      for datetime in event_datetimes
        if (datetime.start_date<Time.now)
        return true
      end
      end
      return false
    end
    
    def get_at_jobs
      at_jobs_array = []
      for datetime in self.event_datetimes
        if datetime.at_job != 0
          at_jobs_array << datetime.at_job
        end
      end
      logger.debug("at_jobs_array " + at_jobs_array.to_s)
      return at_jobs_array
    end
    
    #Method to create the at_jobs
    def create_at_jobs
      logger.debug("RAILS_ROOT es " + File.expand_path(RAILS_ROOT))
      root = File.expand_path(RAILS_ROOT)
      file_path = root + "/public/" + self.get_xedl_filename
      #We use display :44, where we have an vncserver to listen (in case the machine does not have display)
      #environment = "sh -c DISPLAY=:44";
      #export = "sh -c export DISPLAY";
      #environment_out = %x{environment}
      #export_out = %x{export}
      #antes hacía (mal) environment = "DISPLAY=:0 PATH=/home/Enrique/bin:/usr/local/bin:/usr/bin:/usr/X11R6/bin:/bin:/usr/games:/opt/gnome/bin:/opt/kde3/bin HOME=/home/Enrique";
      libraries = " /usr/local/isabel/libexec/isabel_tunnel.jar:/usr/local/isabel/extras/libexec/xmlrpc/commons-logging-1.1.jar:" + 
      "/usr/local/isabel/extras/libexec/xmlrpc/ws-commons-util-1.0.2.jar:/usr/local/isabel/extras/libexec/xmlrpc/xmlrpc-common-3.1.jar:" + 
      "/usr/local/isabel/extras/libexec/xmlrpc/servlet-api.jar:/usr/local/isabel/extras/libexec/xmlrpc/xmlrpc-client-3.1.jar:" +
      "/usr/local/isabel/extras/libexec/xmlrpc/xmlrpc-server-3.1.jar:" +
      "/usr/local/isabel/libexec/isabel_xlimservices.jar:/usr/local/isabel/libexec/xedl.jar:" + 
      "/usr/local/isabel/libexec/isabel_xlim.jar:/usr/local/isabel/lib/images/xlim/:"+
      "/usr/local/isabel/libexec/isabel_lib.jar -Dprior.config.file=/usr/local/isabel/lib/xlimconfig/priorxedl.cfg"+
      " -Disabel.dir=/usr/local/isabel/ -Disabel.profiles.dir=/home/ebarra/.isabel/config/profiles/4.11" +
      " -Disabel.sessions.dir=/home/ebarra/.isabel/sessions/4.11 -Disabel.user.dir=/home/ebarra/.isabel" + 
      " -Disabel.config.dir=/home/ebarra/.isabel/config "         
                 
      command = "java -cp " + libraries + "services/isabel/services/isabellauncher/StartConference " +
      file_path + " --start --mir --email barraorion@gmail.com";
      commandend= "java -cp " + libraries + "services/isabel/services/isabellauncher/StartConference " +
      file_path + " --stop --mir";
      #We stop the session running in the machines 3 minutes (180 seconds) before this session start 
      #and start this session 60 seconds before the official starting time
      #also at the official time we try to start again in case any site did not start
      for datetime in self.event_datetimes
        if (datetime.start_date>Time.now)
          stop_previous_session = (datetime.start_date-180).strftime("%H:%M") + " " + datetime.start_date.strftime("%m/%d/%Y")
          start_time = (datetime.start_date-60).strftime("%H:%M") + " " + datetime.start_date.strftime("%m/%d/%Y")
          real_start_time = datetime.start_date.strftime("%H:%M") + " " + datetime.start_date.strftime("%m/%d/%Y")
          end_time = datetime.end_date.strftime("%H:%M") + " " + datetime.end_date.strftime("%m/%d/%Y")
          logger.debug("stop_previous es " + stop_previous_session)
          logger.debug("start time es " + start_time)
          logger.debug("real start time es " + real_start_time)
          logger.debug("end_time es " + end_time)      
          
          #echo -e $comando | at $at_hour $at_date 2>&1 | grep job | awk '{print $2}
          full_command_stop_previous = "echo " + commandend + " | at " + stop_previous_session + " 2>&1 | grep job | awk '{print $2}'"
          object_IO = IO.popen(full_command_stop_previous)
          if object_IO
            array = object_IO.readlines
            at_job_stop_previous = array[0].to_i
          end        
          logger.debug("salida del comando at stop previous " + at_job_stop_previous.to_s)     
          
          
          full_command_start = "echo " + command + " | at " + start_time + " 2>&1 | grep job | awk '{print $2}'"
          logger.debug("full_command_start: \n" + full_command_start)
          object_IO = IO.popen(full_command_start)
          if object_IO
            array = object_IO.readlines
            at_job_start = array[0].to_i
          end        
          logger.debug("salida del comando at start " + at_job_start.to_s)     
          
          full_command_real_start = "echo " + command + " | at " + real_start_time + " 2>&1 | grep job | awk '{print $2}'"
          logger.debug("full_command_start: \n" + full_command_start)
          object_IO = IO.popen(full_command_real_start)
          if object_IO
            array = object_IO.readlines
            at_job_real_start = array[0].to_i
          end        
          logger.debug("salida del comando at real_start " + at_job_real_start.to_s)     
          
          
          
          full_command_end = "echo " + commandend + " | at " + end_time + " 2>&1 | grep job | awk '{print $2}'"      
          object_IO =  IO.popen(full_command_end)
          if object_IO
            array = object_IO.readlines
            at_job_end = array[0].to_i
          end        
          logger.debug("salida del comando at end " + at_job_end.to_s)     
          
          #I only need the at_job_start but I generated the at_job_end and at_job_stop_previous to 
          #wait fot the command to be executed
          datetime.at_job = at_job_start
          
          logger.debug("at_jobs asignados")
          datetime.save
          logger.debug("datetime salvado")
        elsif (datetime.start_date<Time.now && datetime.end_date > Time.now)
          logger.debug("Se ha cambiado la hora de final de un evento que se esta ejecutando")
          end_time = datetime.end_date.strftime("%H:%M") + " " + datetime.end_date.strftime("%m/%d/%Y")
          logger.debug("end_time es " + end_time)      
          
          full_command_end = "echo " + commandend + " | at " + end_time + " 2>&1 | grep job | awk '{print $2}'"      
          object_IO =  IO.popen(full_command_end)
          if object_IO
            array = object_IO.readlines
            at_job_end = array[0].to_i
          end        
          logger.debug("salida del comando at end " + at_job_end.to_s)     
          
          datetime.at_job = at_job_end
          
          logger.debug("at_jobs asignados")
          datetime.save
          logger.debug("datetime salvado")
        end
      end
    end
    
  #Method to delete the olds at_jobs
    def delete_at_jobs(at_jobs_array)
      #debugger
      if at_jobs_array.length == 1 && at_jobs_array[0]==nil
        return
      end
      at_command_rm = "atrm "
      logger.debug("borrando at_jobs " + at_jobs_array.to_s)
      for at_job in at_jobs_array
        logger.debug("entra en el for")
        command = at_command_rm + at_job.to_s
        #delete also the at_job to start the real session
        command2 = at_command_rm + (at_job+1).to_s
        #delete also the at_job to stop the session
        command3 = at_command_rm + (at_job+2).to_s
        #delete also the at_job to stop the previous session
        command4 = at_command_rm + (at_job-1).to_s      
        logger.debug("at_job comando para borrar es " + command)
        io = IO.popen(command)
        logger.debug("at_job comando para borrar es " + command2)
        io = IO.popen(command2)
        logger.debug("at_job comando para borrar es " + command3) 
        io = IO.popen(command3)
        logger.debug("at_job comando para borrar es " + command4)
        io = IO.popen(command4)
      end  
    end
    
    #Method to create and save in a file the xedl for a session
    def create_and_save_xedl
      logger.debug("CREANDO XEDL para el evento " + self.name)
      xedl_sesion = XedlController.create_session(1.9,self.name,"Isabel 4.11.r1",self.service,self.quality)
      i = 0;
      sites = []
      for participant in self.participants
        participant_name = Machine.find(participant.machine_id).name
        participant_address = Machine.find(participant.machine_id).nickname
        if participant.machine_id_connected_to != 0
          address_connected_to = Machine.find(participant.machine_id_connected_to).nickname
        else
          address_connected_to = nil #master
        end
        logger.debug("el fec es " + participant.fec.to_s)
        #breakpoint()
        sites[i] = XedlController.create_options(participant_name,self.password,"UPM",participant_address,address_connected_to,
        participant.role,participant.fec,participant.radiate_multicast)
        i += 1
      end
      xedl_total = XedlController.create_xedl(xedl_sesion,sites)
      logger.debug("XEDL ES: " + xedl_total)
      nombre_fichero = self.get_xedl_filename 
      logger.debug("nombre del xedl a guardar " + nombre_fichero)
      
      fh = File.new(nombre_fichero, "w")
      fh.puts xedl_total
      fh.close
    end
    
    
    def delete_file (file_to_delete)
            logger.debug("nombre del xedl a borrar " + file_to_delete)
            if File.exist?(file_to_delete)
                  FileUtils.rm file_to_delete
                  logger.debug("primero hemos borrado el antiguo si lo había")
            end
    end
    
    #Method that search in events with pagination
   def self.full_text_search(q, options = {})
    return nil if q.nil? or q==""
    default_options = {:limit => 10, :page => 1}
    options = default_options.merge options
   
    # get the offset based on what page we're on
    options[:offset] = options[:limit] * (options.delete(:page).to_i-1)  
   
    # now do the query with our options
    results = Event.find_by_contents(q, options)
    
    return [results.total_hits, results]
  end
  #method that make an advanced search in events with pagination
  def self.full_text_search2(q, options = {})
    return nil if q.nil? or q==""
    default_options = {:limit => 10, :page => 1}
    options = default_options.merge options
   
    # get the offset based on what page we're on
    options[:offset] = options[:limit] * (options.delete(:page).to_i-1)  
 
    # now do the query with our options
      q1 = "*" + q + "*"
    results = Event.find_by_contents(q1, options)
    return [results.total_hits, results]
  end
  #Method that search by title
  def self.title_search(q, options = {})
    return nil if q.nil? or q==""
    default_options = {:limit => 10, :page => 1}
    options = default_options.merge options
   
    # get the offset based on what page we're on
    options[:offset] = options[:limit] * (options.delete(:page).to_i-1)  
 
    # now do the query with our options
      q2 = "name:" + q + "*"
    results = Event.find_by_contents(q2, options)
    return [results.total_hits, results]
  end
  #Method that search in the description
  def self.description_search(q, options = {})
    return nil if q.nil? or q==""
    default_options = {:limit => 10, :page => 1}
    options = default_options.merge options
   
    # get the offset based on what page we're on
    options[:offset] = options[:limit] * (options.delete(:page).to_i-1)  
 
    # now do the query with our options
      q2 = "description:" + q + "*"
    results = Event.find_by_contents(q2, options)
    return [results.total_hits, results]
  end
  
  #Method that search by dates
  def self.date_search(q,q2, options = {})
    return nil if q.nil? or q=="" or q2.nil? or q2==""
    default_options = {:limit => 10, :page => 1}
    options = default_options.merge options
   
    # get the offset based on what page we're on
    options[:offset] = options[:limit] * (options.delete(:page).to_i-1) 
 #cambiamos el formato de las fechas,, creando un objeto de tipo date y transformandolo
   #a formato Ymd => 20081124
    date1 = Date.parse(q)
   date1ok =  date1.strftime("%Y%m%d")
   date2 = Date.parse(q2)
   date2ok =  date2.strftime("%Y%m%d")

    
   query = Ferret::Search::RangeQuery.new(:start_dates , :>= => date1ok, :<= => date2ok)
    # now do the query with our options
     
    results = Event.find_by_contents(query, options)
    return [results.total_hits, results,query]
  end
  
  def start_dates 
    date =[]
    i = 0
    self.event_datetimes.sort!{|x,y| x.start_date <=> y.start_date}
    for datetime in self.event_datetimes
     
      date[i] = datetime.start_date.strftime("%d  %b %Y %H:%M")
      
      i += 1
      end
     return date
   end
  
  
    private
  #conditions for participants:
  #  do not appear twice or more times
  #  do not connect to one participant that does not belongs to the conference
  #  every participant has to reach the master, directly or through another participant(s)    
  def validate_participants(array_participants)
     #array of participants
     @array_participants = []
     #array of the places to wich my participants are connected
     @array_connections = []
     @already_branched = []
     @bad_connections = []
     for participant in array_participants
       logger.debug("PARTICIPANT EN ARRAY_PARTICIPANTS " + participant.machine_id.to_s)
       result = true
       @array_participants << participant.machine_id 
       @array_connections << participant.machine_id_connected_to
       if participant.machine_id==participant.machine_id_connected_to
         errors.add(:participants, ": " +Machine.find(participant.machine_id).name + " is connected to himself")
         result = false
       end
     end
     #validate that the numbers appearing in the array connections also appear in array_participants
     for i in @array_connections
       if i==0
         next  #is the master, 0 indicates not connected to anybody
       end
       if @array_participants.index(i)==nil
           errors.add(:participants, ": " +Machine.find(@array_participants[@array_connections.index(i)]).name + 
               " is connected to " + Machine.find(i).name + " and " +
               Machine.find(i).name + " is not a participant")
           result = false
           @bad_connections << @array_participants[@array_connections.index(i)]
       end
     end
     #validates that the numbers in array_participants are not repeated
     array_participants_temp = []
     array_participants_temp.replace(@array_participants)
     for ind in 1..@array_participants.size
       parti = array_participants_temp.pop  #this is no longer in the array temp, i test if there is another occurrence?
       if array_participants_temp.index(parti)!=nil
           errors.add(:participants, ": " +Machine.find(parti).name + " is repeated")
           result = false
       end
     end
     logger.debug("array_participants LOOK LOOK " + @array_participants.to_s)
     logger.debug("array_connexions " + @array_connections.to_s)
     
       for i in 0..(@array_participants.size-1)
          if @bad_connections.index(@array_participants[i])!=nil
            #the participant is bad connected, he will never reach the master
            next
          end     
          if !is_connected_to_master?(@array_participants[i])
            errors.add(:participants,": " +Machine.find(@array_participants[i]).name + " has no connection to the master")
            result = false
          end
       end
       return result
  end
  
    
  #conditions for datetime:
  #  end_time and start_time in the future time
  #  end_time after start_time
  #  do not overlap with other datetimes of this event
  #  do not overlap with other datetimes of another event involving the same machines
  def validate_datetime(array_datetimes)
     result = true
     indice = 1
     logger.debug("ARRAY_DATETIMES.SIZE " +array_datetimes.size.to_s)
     for datetime in array_datetimes
       if (datetime.end_date<datetime.start_date) 
         errors.add(:datetimes, "the " +get_ordinal(indice) + " date entry is incorrect,"+
                     " end date is before start date")
         result = false
       end
       #if (datetime.start_date<Time.now)
       #  errors.add(:datetimes, "the " +get_ordinal(indice) + " date entry is incorrect,"+
       #              " the event can't be accomplished in the past")
       #  result = false
       #end      
       index_overlap = overlaps_with_another?(datetime.start_date,datetime.end_date,indice,event_datetimes)
       if index_overlap
         errors.add(:datetimes, "the " +get_ordinal(indice) + " date entry is incorrect," +
                  " it overlaps with the " + get_ordinal(index_overlap+1) + " date entry"  ) 
       
         result = false
       end
       event_overlap_hash = overlaps_with_another_event?(datetime.start_date,datetime.end_date)      
       if event_overlap_hash
         logger.debug("hay overlap con otro evento ")
         coincidences = event_overlap_hash[:coincidences]
         machines_overlap = Machine.find(coincidences.pop).name
         for ii in coincidences
           machines_overlap += " and " + Machine.find(ii).name
         end
         errors.add(:datetimes, "the " +get_ordinal(indice) + " date entry is incorrect," +
                  " it overlaps with event named \"" + event_overlap_hash[:event_name] + "\" using " + machines_overlap)       
         result = false
       end
       indice += 1
     end
     return result
  end
  
  
  #method to now if a datetime overlaps with another datetime 
  #from another event that uses the same machines
  #returns a hash with the event name of the overlapping and the machine names
  def overlaps_with_another_event?(start_date,end_date)
     #eventos = []
     eventos = Event.find(:all)
     for eventin in eventos
       if eventin.id==id
         next   #is this same event
       end
       #coincidences = []
       coincidences = eventin.contains_participants(@array_participants)
       if coincidences.size>0
         #use same machines
         index_overlap = overlaps_with_another?(start_date,end_date,0,eventin.event_datetimes)
         if index_overlap
           #overlap in datetimes and machines, returns a hash
           the_hash = {:event_name =>eventin.name, :coincidences => coincidences}
           return the_hash
         end
       end
     end
     return nil
  end
  
  
  #method to know if a datetime overlaps with another datetime in datetimes
  #we only test from indice to the end of the entries
  #we will use this method to help testing if there is overlapping with other events
  #passing the other event datetimes_array and an index of 0
  #is_for_timetable indicates if the result of this method will be for the presentation at the timetable
  #in that case if an event ends at 13:33 and the next one starts at 13:45 they overlap because they are
  #presented as finishing at the same hour
  def overlaps_with_another?(start_date, end_date, indice, datetimes_array, is_for_timetable=false)
     #to overlap start_date or end_date can be in the middle of datetime or
     #start_date can be before and end_date after, so contains the full datetime     
     for index in (indice)..(datetimes_array.size-1)
         logger.debug("COMPROBANDO EL INDICE " +index.to_s)
         if datetimes_array[index].start_date<=start_date && datetimes_array[index].end_date>=start_date
           return index
         end
         if datetimes_array[index].start_date<=end_date && datetimes_array[index].end_date>=end_date
           return index
         end
         if start_date<=datetimes_array[index].start_date && end_date>=datetimes_array[index].end_date
           return index
         end
         if is_for_timetable
           if start_date.day==datetimes_array[index].end_date.day && start_date.hour==datetimes_array[index].end_date.hour
             return index
           end
           if end_date.day==datetimes_array[index].start_date.day && end_date.hour==datetimes_array[index].start_date.hour
             return index
           end
         end
     end 
     return nil
  end
      
  
  #the only way of not being connected to the master is creating a bucle
  # 1 connected to 2 and 2 to 3 and 3 to 1, so i try to detect that
  def is_connected_to_master?(participant)
     logger.debug("comprobando si esta conectado a master " + participant.to_s)
     @already_branched << participant
     indice = @array_participants.index(participant)
     father = @array_connections.at(indice) #see who is the participant connected to
       if(father == 0)
          @already_branched = []  #next step we will validate another branch
          return true  #if it is the master return true
       elsif @already_branched.index(father)!=nil
          #bucle
          @already_branched = []
          return false
       else
          #else we return true if our father is connected to the master
          return is_connected_to_master?(father)
       end     
  end 
  
  
  #private method to get the ordinal corresponding to a fixnum
  #returns a string containing the ordinal
  def get_ordinal(indice)
     if indice==1
       return "first"
     elsif indice==2
       return "second"
     elsif indice==3
       return "third"
     else 
       return indice.to_s+"rd"
     end
  end
  
  
  def self.get_Service_name(activity_name)
     if activity_name == "class.act"
       return "TeleClass"
     elsif activity_name == "conference.act"
       return "TeleConference"
     elsif activity_name == "meeting.act"
       return "TeleMeeting"
     else
       return "TeleMeeting"
     end
  end
  
 
    
  
end
