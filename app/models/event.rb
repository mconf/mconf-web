# Copyright 2008-2010 Universidad Politécnica de Madrid and Agora Systems S.A.
#
# This file is part of VCC (Virtual Conference Center).
#
# VCC is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# VCC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with VCC.  If not, see <http://www.gnu.org/licenses/>.

require 'pdf/writer'
require 'pdf/simpletable' #To manage tables. 
require 'iconv'

class Event < ActiveRecord::Base
  belongs_to :space
  belongs_to :author, :polymorphic => true
  has_many :posts
  has_many :participants
  has_many :event_invitations, :dependent => :destroy
  has_many :attachments, :dependent => :destroy
  has_one :agenda, :dependent => :destroy
  
  has_logo :class_name => "EventLogo"
  has_permalink :name, :update=>true
  
  acts_as_resource :per_page => 10, :param => :permalink
  acts_as_content :reflection => :space
  acts_as_taggable
  acts_as_stage
  acts_as_container :content => :agenda
  alias_attribute :title, :name
  validates_presence_of :name, :start_date , :end_date,
                          :message => "must be specified"
  
  # Attributes for jQuery selectors
  attr_accessor :end_hour
  attr_accessor :mails
  attr_accessor :ids
  attr_accessor :notification_ids
  attr_accessor :invite_msg
  attr_accessor :external_streaming_url 
  
  #Attibutes for Conference Manager
  attr_accessor :web_interface
  attr_accessor :isabel_interface
  attr_accessor :sip_interface
  #Attributes for ConferenceManager video display
  attr_accessor :web_width
  attr_accessor :web_heigth
  attr_accessor :player_width
  attr_accessor :player_height
  attr_accessor :editor_width
  attr_accessor :editor_height
  attr_accessor :streaming_width
  attr_accessor :streaming_height
  
  is_indexed :fields => ['name','description','place','start_date','end_date', 'space_id'],
             :include =>[{:class_name => 'Tag',
                          :field => 'name',
                          :as => 'tags',
                          :association_sql => "LEFT OUTER JOIN taggings ON (events.`id` = taggings.`taggable_id` AND taggings.`taggable_type` = 'Event') LEFT OUTER JOIN tags ON (tags.`id` = taggings.`tag_id`)"},
  {:class_name => 'User',
                               :field => 'login',
                               :as => 'login_user',
                               :association_sql => "LEFT OUTER JOIN users ON (events.`author_id` = users.`id` AND events.`author_type` = 'User') "}
  ]
  
  VC_MODE = [:in_person, :meeting, :teleconference]

  validate_on_create do |event|
   if event.start_date.to_date.past?
     event.errors.add_to_base(I18n.t('event.error.date_past'))
   end
   if (event.vc_mode == Event::VC_MODE.index(:meeting)) || ( event.vc_mode == Event::VC_MODE.index(:teleconference))
      mode = ""
      if event.vc_mode == Event::VC_MODE.index(:meeting)
        mode = "meeting"
      elsif event.vc_mode == Event::VC_MODE.index(:teleconference)
          mode = "conference"
      end 
      cm_e = ConferenceManager::Event.new(:name=> event.name, :mode =>mode, :enable_web => event.web_interface , :enable_isabel => event.isabel_interface, :enable_sip => event.sip_interface, :path => "attachments/conferences/#{event.permalink}")
      begin 
       cm_e.save
       event.cm_event_id = cm_e.id
     rescue StandardError =>e
       event.errors.add_to_base(e.to_s)
      end        
    end  
  end
  
  validate_on_update do |event|
    if (event.vc_mode == Event::VC_MODE.index(:meeting)) || (event.vc_mode == Event::VC_MODE.index(:teleconference))
      mode = ""
      if event.vc_mode == Event::VC_MODE.index(:meeting)
        mode = "meeting"
      elsif event.vc_mode == Event::VC_MODE.index(:teleconference)
          mode = "conference"
      end    
      my_params = {:name=> event.name, :mode =>mode, :enable_web => event.web_interface , :enable_isabel =>event.isabel_interface, :enable_sip => event.sip_interface,:path => "attachments/conferences/#{event.permalink}" }
      cm_event = event.cm_event
      cm_event.load(my_params)  
      begin
        cm_event.save
      rescue  StandardError =>e
        event.errors.add_to_base(e.to_s)  
      end
    end  
  end
  
  before_destroy do |event|
    #Delete event in conference Manager
    if (event.vc_mode == Event::VC_MODE.index(:meeting)) || (event.vc_mode == Event::VC_MODE.index(:teleconference))
      begin
        cm_event = ConferenceManager::Event.find(event.cm_event_id)
        cm_event.destroy  
      rescue => e
        event.errors.add_to_base(I18n.t('event.error.delete'))  
        false
      end
    end
  end

  validate_on_create do |event|
   if (event.vc_mode == Event::VC_MODE.index(:meeting)) || ( event.vc_mode == Event::VC_MODE.index(:teleconference))
      mode = ""
      if event.vc_mode == Event::VC_MODE.index(:meeting)
        mode = "meeting"
      elsif event.vc_mode == Event::VC_MODE.index(:teleconference)
          mode = "conference"
      end 
      cm_e = ConferenceManager::Event.new(:name=> event.name, :mode =>mode, :enable_web => event.web_interface , :enable_isabel => event.isabel_interface, :enable_sip => event.sip_interface, :path => "attachments/conferences/#{event.permalink}")
      begin 
       cm_e.save
       event.cm_event_id = cm_e.id
     rescue StandardError =>e
       event.errors.add_to_base(e.to_s)
      end        
    end  
  end
  
  validate_on_update do |event|
    if (event.vc_mode == Event::VC_MODE.index(:meeting)) || (event.vc_mode == Event::VC_MODE.index(:teleconference))
      mode = ""
      if event.vc_mode == Event::VC_MODE.index(:meeting)
        mode = "meeting"
      elsif event.vc_mode == Event::VC_MODE.index(:teleconference)
          mode = "conference"
      end    
      my_params = {:name=> event.name, :mode =>mode, :enable_web => event.web_interface , :enable_isabel =>event.isabel_interface, :enable_sip => event.sip_interface,:path => "attachments/conferences/#{event.permalink}" }
      cm_event = event.cm_event
      cm_event.load(my_params)  
      begin
        cm_event.save
      rescue  StandardError =>e
        event.errors.add_to_base(e.to_s)  
      end
    end  
  end
  
  before_destroy do |event|
    #Delete event in conference Manager
    if (event.vc_mode == Event::VC_MODE.index(:meeting)) || (event.vc_mode == Event::VC_MODE.index(:teleconference))
      begin
        cm_event = ConferenceManager::Event.find(event.cm_event_id)
        cm_event.destroy  
      rescue => e
        event.errors.add_to_base(I18n.t('event.error.delete'))  
        false
      end
    end
  end
 
  after_create do |event|
    #create an empty agenda
    event.agenda = Agenda.create
    #create a directory to save attachments
    FileUtils.mkdir_p("#{RAILS_ROOT}/attachments/conferences/#{event.permalink}") 
  end
  
  after_save do |event|
    if event.mails
      #NOT ANY MORE: first of all we remove the emails that already has an invitation for this event (not to spam them)
      #mails_to_invite = event.mails.split(/[\r,]/).map(&:strip) - event.event_invitations.map{|ei| ei.email}
      mails_to_invite = event.mails.split(/[\r,]/).map(&:strip)
      mails_to_invite.map { |email|      
        params =  {:role_id => Role.find_by_name("User").id.to_s, :email => email, :event => event, :comment => event.invite_msg}
        i = event.space.event_invitations.build params
        i.introducer = event.author
        i
      }.each(&:save)
    end
    if event.ids
      event.ids.map { |user_id|
        user = User.find(user_id)
        params = {:role_id => Role.find_by_name("User").id.to_s, :email => user.email, :event => event, :comment => event.invite_msg}
        i = event.space.event_invitations.build params
        i.introducer = event.author
        i
      }.each(&:save)
    end
    if event.notification_ids
      event.notification_ids.each { |user_id|
        user = User.find(user_id)
        params = {:event => event, :email => user.email, :sender_login => event.author.login, :receiver_login => user.login, :comment => event.notify_msg}
        n = EventNotification.build params
        Informer.deliver_event_notification(n)
      }
    end
  end
  
  def author
    User.find_with_disabled(author_id)
  end
  
  def space
    Space.find_with_disabled(space_id)
  end      
  
  def organizers
    if actors.size == 0
      ar = Array.new
      ar << author
      return ar
    end
    actors
  end
  
  #return the number of days of this event duration
  def days
    (end_date.to_date - start_date.to_date).to_i     
  end
  
  #returns the day of the agenda entry, 0 for the first day, 1 for the second day, ...
  def day_for(agenda_entry)
    return agenda_entry.start_time.to_date - start_date.to_date
  end
  
  #returns the hour of the last agenda_entry
  def last_hour_for_day(day)
    ordered_entries = agenda.agenda_entries_for_day(day).sort{|x,y| x.end_time <=> y.end_time }
    unless ordered_entries.empty?
      ordered_entries.last.end_time
    else
      if (start_date + day.days).day == Time.now.day
        Time.now
      else
        self.start_date + day.days + 9.hour
      end  
    end  
  end
  
  def entries_ordered_by_date
    agenda.agenda_entries.sort{|x,y| x.end_time <=> y.end_time}  
  end
  
  def syncronize_date
     self.start_date = entries_ordered_by_date.first.start_time
     self.end_date = entries_ordered_by_date.last.end_time
  end
    
    
  #method to know if this event is happening now
  def is_happening_now?
     return !start_date.future? && end_date.future?
  end
  
  #method to know if an event happens in the future
  def future?
    return start_date.future?    
  end
  
  #method to know if an event happens in the past
  def past?
    return end_date.past?
  end
  
  def get_attachments
    return Attachment.find_all_by_event_id(id)
  end
  
  #method to get the starting date of an event in the correct format
  #the problem is that the starting hour comes from the agenda
  def get_formatted_date
    if agenda.present? && agenda.agenda_entries.count>0
      first_entry = agenda.agenda_entries.sort_by{|x| x.start_time}[0]
      #check that the entry is the first day
      if first_entry.start_time > start_date && first_entry.start_time < start_date + 1.day
        return I18n::localize(first_entry.start_time, :format => "%A, %d %b %Y") + " " + I18n::translate('date.at') + " " + first_entry.start_time.strftime("%H:%M") + " (GMT " + Time.zone.formatted_offset + ")"
      else
        return I18n::localize(start_date.to_date, :format => "%A, %d %b %Y")
      end
    end
    return I18n::localize(start_date.to_date, :format => "%A, %d %b %Y")
  end
  
  
  #method to get the starting hour of an event in the correct format
  #the problem is that the starting hour comes from the agenda
  def get_formatted_hour
    if agenda.present? && agenda.agenda_entries.count>0
      first_entry = agenda.agenda_entries.sort_by{|x| x.start_time}[0]
      #check that the entry is the first day
      if first_entry.start_time > start_date && first_entry.start_time < start_date + 1.day
        return first_entry.start_time.strftime("%H:%M")
      else
        return ""
      end
    end
    return ""
  end
  
  
  def validate
    if self.start_date.nil? || self.end_date.nil? 
      errors.add_to_base(I18n.t('event.error.omit_date'))
    else
      unless self.start_date < self.end_date
        errors.add_to_base(I18n.t('event.error.dates1'))
      end  
    end
    if self.marte_event? && ! self.marte_room?
      #check connectivity with Marte
      begin
        MarteRoom.find(:all)
      rescue => e
        errors.add_to_base(I18n.t('event.error.marte'))
      end
    end
    #    unless self.start_date.future? 
    #      errors.add_to_base("The event start date should be a future date  ")
    #    end
  end
  
  after_save do |event|
    if event.marte_event? && ! event.marte_room? && !event.marte_room_changed?
      mr = begin
        MarteRoom.create(:name => event.id)
      rescue => e
        logger.warn "Failed to create MarteRoom: #{ e }"
        nil
      end
      
      event.update_attribute(:marte_room, true) if mr
    end
  end
  
  after_destroy do |event|
    
    FileUtils.rm_rf("#{RAILS_ROOT}/attachments/conferences/#{event.permalink}") 
    if event.marte_event? && event.marte_room?
      begin
        MarteRoom.find(event.id).destroy
      rescue
      end
    end     
  end
  
  def cm_event?
    cm_event.present?
  end
  
  def cm_event
    begin
      @cm_event ||= ConferenceManager::Event.find(self.cm_event_id)
    rescue
      nil
    end  
  end
  
  def sip_interface?
      cm_event.try(:enable_sip?)
  end
  
  def isabel_interface?
      cm_event.try(:enable_isabel?)  
  end
  
  def web_interface?
      cm_event.try(:enable_web?)  
  end
  
  def web_url
      cm_event.try(:web_url)
  end
  
  def sip_url
      cm_event.try(:sip_url)
  end
  
  def isabel_url
      cm_event.try(:isabel_url) 
  end
  
  #Return  a String that contains a html with the video of the Isabel Web Gateway
  def web
    begin
      cm_web ||= ConferenceManager::Web.find(:one,:from=>"/events/#{self.cm_event_id}/web")
      cm_web.html
    rescue
      nil
    end
  end
  
  #Return  a String that contains a html with the video player for this conference
  def player
    begin
      cm_player ||= ConferenceManager::Player.find(:one,:from=>"/events/#{self.cm_event_id}/player")
      cm_player.html
    rescue
      nil
    end
  end
  #Return  a String that contains a html with the video editor for this conference
  def editor
    begin
      cm_editor ||= ConferenceManager::Editor.find(:one,:from=>"/events/#{self.cm_event_id}/editor")
      cm_editor.html
    rescue
      nil
    end
  end
  #Return  a String that contains a html with the streaming of this conference
  def streaming
    begin
      cm_streaming ||= ConferenceManager::Streaming.find(:one,:from=>"/events/#{self.cm_event_id}/streaming")
      cm_streaming.html
    rescue
      nil
    end
  end
    
  def get_room_data
    return nil unless marte_event?
    
    begin
      MarteRoom.find(self.id)
    rescue
      update_attribute('marte_room', false) if attributes['marte_room']
      nil
    end
  end
  
  authorizing do |agent, permission|
    if ( permission == :update || permission == :delete ) && author == agent
      true
    end
  end
  
   
  #Method to generate the agenda of the event in PDF.
  def to_pdf
    
    #Parameters used.
    @event = self
    
    @agenda = @event.agenda
    
    pdf = PDF::Writer.new(:paper => "A4", :orientation => :landscape )
   
    #Create a gradient, at the top right corner.
    r1 = 25
    30.step(-1, -3) do |xw|
      tone = 1.0 - (xw / 40.0) * 0.2  #Parameter to control the brightness of the gradient.
      color = 0x400ee3  #Parameter to change the color of the gradient.
      pdf.stroke_style(PDF::Writer::StrokeStyle.new(xw))
      pdf.stroke_color(Color::RGB.from_fraction(tone,3250,color))
      pdf.circle_at(850, 650, r1).stroke
      r1 += xw
    end

    pdf.margins_pt(25, 30, 25, 30)   #pdf.margins_pt(Top, Left, Bottom, Right)

    #Parameters of the the table.
    c1_width = 75
    c2_width = 135
    c3_width = 170
    c4_width = 360
   
    pdf.select_font("Helvetica" , { :encondig => "WinAnsiEnconding" } )
    pdf.start_page_numbering(pdf.margin_x_middle, 5, 10, nil, nil, 1)

    i1 = "#{RAILS_ROOT}/public/images/cabeceraVCC_pdf.jpg"
    i2 = "#{RAILS_ROOT}/public/images/vcc-logo_pdf.jpg"
    pdf.image i1, :justification => :right, :resize => 1
    pdf.image i2, :justification => :left, :resize => 0.7
 
    write_event_title(pdf,@event.name)


    @event.days.times do |i|
        
      date = (@event.start_date+i.day).strftime("%A %d %b")

      @entries = @agenda.agenda_entries_for_day(i)
    
      unless i == @event.days or i == 0 or @entries.empty?
        pdf.start_new_page  
      end
 
      @entries_array = fragment_entries(@entries)
       
      @entries_array.each do |entries|
           
      if entries == @entries_array[0]
        #First entrie in the day. Its a special case.

        #if entries[0].special_title    #The first entrie in the day has a special title.
        if random_boolean(0)
          pdf.fill_color  Color::RGB::Black
          pdf.text "#{date}", :font_size => 14, :justification => :center
          pdf.text " ", :font_size => 2
        
          #Two types of special titles. To test we will chose one of them randomly.
          if random_boolean(50)
            write_special_title(pdf,c1_width + c2_width,c3_width + c4_width,entries[0],true)
          else
            write_special_title_b(pdf,c1_width + c2_width,c3_width + c4_width,entries[0],true)
          end

          if entries.length > 1
            generate_entrie_table(pdf,c1_width,c2_width,c3_width,c4_width,entries,nil      ,   true,       false)
            #generate_entrie_table(pdf,c1_width,c2_width,c3_width,c4_width,entries,tab_title,heading,first_entrie)
          end
          
        else
          generate_entrie_table(pdf,c1_width,c2_width,c3_width,c4_width,entries,date     ,   true,        true)
        end
            
      else
        #if entries[0].special_title 
        if random_boolean(0)         
          write_special_title_b(pdf,c1_width + c2_width ,c3_width + c4_width,entries[0],true)
            
          if entries.length > 1
            generate_entrie_table(pdf,c1_width,c2_width,c3_width,c4_width,entries,nil,false,false)
          end
            
          else
            generate_entrie_table(pdf,c1_width,c2_width,c3_width,c4_width,entries,nil,true,true)
          end
          
        end 
        
      end 
      
    end     #All Day Ends. PDF finished.
    
    pdf.render
   
  end
  
  
  
  private
  
  #Returns a random boolean, only for test.
  #trueProbability is a number in the range (0,100) (%)
  def random_boolean(trueProbability)
    
    @random_boolean = false
    num_aleat = rand(10)

    if num_aleat > (9-(trueProbability/10))
      @random_boolean = true
    end
    
    @random_boolean
    
  end
  
  
  #Fragment the entries of one day.
  #Returns a array of entries, i.e , a array of entrie arrays.
  #It used to fragment the inicial table of one day into two or more tables around the entries with special titles.
  def fragment_entries(entries)
    
    array_entries = []
    entries_temp = []
    
    entries.each do |entrie|    
      
      #if entrie.special_title
      if random_boolean(0)
        entries_temp << entrie
        array_entries << entries_temp
        entries_temp = []
      else
        entries_temp << entrie
          
        if entrie==entries[entries.length-1]
          array_entries << entries_temp
        end
        
      end
      
    end

    array_entries
   
  end
     
  #Generate and fill a table with the dates contained in entries.
  #tab_title Title of the table. Nil if we want the table without title.
  #heading True to show the table heading.
  #First_entrie False if we want to ignore the first row in the table.
  def generate_entrie_table(pdf,c1_width,c2_width,c3_width,c4_width,entries,tab_title,heading,first_entrie)
    
    @entries = entries
    
    PDF::SimpleTable.new do |tab|
    
    if tab_title
      tab.title = tab_title
      tab.title_color = Color::RGB::Black
      tab.title_font_size = 14
      tab.title_gap = 8
    end 

    tab.row_gap = 3
    
    tab.show_lines =:all
    tab.show_headings = heading
    tab.bold_headings = true
    tab.shade_headings  = true
    tab.heading_font_size = 11
    tab.orientation = :center
    tab.position = :center
    tab.minimum_space = 50
    tab.shade_heading_color = Color::RGB.new(134,154,184)
    tab.shade_color = Color::RGB::Grey90
    tab.text_color = Color::RGB::Black

    tab.column_order = ["col1","col2","col3","col4"]
    
    tab.columns["col1"] = PDF::SimpleTable::Column.new("col1") { 
      |col| 
      col.width = c1_width
      col.heading = "Hour"
      col.heading.justification = :center 
    }
    
    tab.columns["col2"] = PDF::SimpleTable::Column.new("col2") { 
      |col| 
      col.width = c2_width
      col.heading = "Title" 
      col.heading.justification = :center   
    }
    
    tab.columns["col3"] = PDF::SimpleTable::Column.new("col3") { 
      |col| 
      col.width = c3_width
      col.heading = "Speakers"
      col.heading.justification = :center 
    }
    
    tab.columns["col4"] = PDF::SimpleTable::Column.new("col4") { |col| 
      col.width = c4_width
      col.heading = "Description" 
      col.heading.justification = :center    
    }
    

    data = []
    
      @entries.each do |entrie|
      
        hour =  entrie.start_time.strftime("%H:%M").to_s() + " to " + entrie.end_time.strftime("%H:%M").to_s() 
        
        unless !first_entrie and (entrie == @entries[0])
          add_row(tab,data,hour,entrie.title,entrie.speakers,entrie.description)
        end
 
      end
    
      tab.render_on(pdf)

    end
  
  end
  
  
  #Method to add a row in the table tab.
  def add_row(tab,data,hour,title,speakers,description)       
    data << { "col1" => text_to_iso("#{hour}"), "col2" => text_to_iso("#{title}"), 
    "col3" => text_to_iso("#{speakers}"), "col4" => text_to_iso("#{description}") }
    tab.data.replace data      
  end
  
  def text_to_iso(text)
    c = Iconv.new('ISO-8859-15//IGNORE//TRNSLIT', 'UTF-8')
    c.iconv(text)
  end
  
  
  #Write the event title. Decrement font-size in function of the title's lenght.
  def write_event_title(pdf,event_name)
   
    pdf.text " ", :font_size => 12
    
    #If the lenght is in the range (function_lenght_min,function_lenght_max), applying a function 
    #to decrement one font-size point every "function_scale" letters added.
    function_lenght_max = 45
    function_lenght_min = 9
    function_scale = 2
   
    font_size_event_title_max = 33
    font_size_event_title_min = font_size_event_title_max - ((function_lenght_max-function_lenght_min)/function_scale)
   
    font_size_event_title = font_size_event_title_max
   
    if event_name.length > function_lenght_max
      font_size_event_title = font_size_event_title_min
    else 
      if event_name.length > function_lenght_min    
        dif = (event_name.length - function_lenght_min)/function_scale
        font_size_event_title -= dif
      end
    end
   
    pdf.select_font("Helvetica-Bold", { :encondig => "WinAnsiEnconding" } )
    pdf.text text_to_iso(event_name), :font_size => font_size_event_title, :justification => :center
    pdf.select_font("Helvetica" , { :encondig => "WinAnsiEnconding" } )
   
    pdf.text " ", :font_size => 30

  end


  #Add special title to the pdf. Model 2
  def write_special_title_b(pdf,width_hour,width_title,entrie,hasHour)
      
    vccColor = Color::RGB.new(36, 73, 116)
    pdf.text " ", :font_size => 3
    pdf.select_font("Helvetica", { :encondig => "WinAnsiEnconding" } )

    x = pdf.absolute_left_margin+20    

    #f_rectangle estimated lines occupied by the text.
    title_width = pdf.text_line_width(text_to_iso("#{entrie.title}"), 18)  
    
    if hasHour    
      f_rectangle = (title_width / 590)
    else
      f_rectangle = (title_width / 735)
    end

    #1-4 lines cases are treated specified.
    if f_rectangle < 5
      f_rectangle = f_rectangle.ceil
    else
      f_rectangle = f_rectangle + 1
    end
      
    case f_rectangle
      when 0
        f_rectangle = 1
        h = 29
      when 1
        h = 29
      when 2
        h = 26
      when 3
        h = 24
      when 4
        h = 22
    else
        h = 22
    end


    height_rectangle = h*f_rectangle
 
    bottom_space = pdf.y
    margin_space = 20
      
    #Test if the special title fits in the page.
    if height_rectangle > (bottom_space - margin_space)
      pdf.start_new_page
    end

    last_y = pdf.y

    pdf.fill_color  vccColor
    #rounded_rectangle(x, y, w, h, r)
    #Draw a rounded rectangle with corners (x, y) and (x + w, y - h) and corner radius r. The radius should be significantly smaller than h and w.
    pdf.rounded_rectangle(pdf.absolute_left_margin+20, pdf.y, 735, height_rectangle, 10).close_fill_stroke
    
    pdf.fill_color  Color::RGB::White
    
    #pdf.margins_pt(25, 30, 25, 30)   #pdf.margins_pt(Top, Left, Bottom, Right) previous margins
    
    if hasHour
      hour =  entrie.start_time.strftime("%H:%M").to_s() + " to " + entrie.end_time.strftime("%H:%M").to_s()
        
      #add_text(x, y, text, size = nil, angle = 0, word_space_adjust = 0)
      #Add text to the document at (x, y) location at size and angle. 
      #The word_space_adjust parameter is an internal parameter that should not be used.
      pdf.add_text(x+20, pdf.y-19, text_to_iso("#{hour}"), 14, 0, 0)      
       
      pdf.margins_pt(25, 200, 25, 55)
    else
      pdf.margins_pt(25, 55, 25, 55)
    end

    pdf.text text_to_iso("#{entrie.title}"), :font_size => 18, :justification => :center
    pdf.margins_pt(25, 30, 25, 30)
    pdf.y = last_y - height_rectangle
    pdf.fill_color  Color::RGB::Black
    pdf.text " ", :font_size => 3 

  end
 
 
  #Add special title to the pdf. Model 1
  def write_special_title(pdf,width_hour,width_title,entrie,hasHour)

    pdf.text " ", :font_size => 2
    pdf.select_font("Helvetica-Bold", { :encondig => "WinAnsiEnconding" } )
    
    @specialTable = PDF::SimpleTable.new do |tab|  
    
      data = [] 
    
      if hasHour
    
        hour =  entrie.start_time.strftime("%H:%M").to_s() + " to " + entrie.end_time.strftime("%H:%M").to_s()
    
        tab.column_order = ["col1","col2"]
    
        tab.columns["col1"] = PDF::SimpleTable::Column.new("col1") { 
          |col| 
          col.width = width_hour
          col.justification = :center
        }
    
        tab.columns["col2"] = PDF::SimpleTable::Column.new("col2") { 
          |col| 
          col.width = width_title
          col.justification = :center
        }
    
        data << { "col1" => text_to_iso("#{hour}"), "col2" => text_to_iso("#{entrie.title}") }
    
        pdf.select_font("Helvetica-Bold", { :encondig => "WinAnsiEnconding" } )
        tab.font_size = 13
    
      else  
    
        tab.column_order = ["col1"]
    
        tab.columns["col1"] = PDF::SimpleTable::Column.new("col1") { 
          |col| 
          col.width = width_hour + width_title
          col.justification = :center
        }

        data << { "col1" => text_to_iso("#{entrie.title}") }
    
        tab.font_size = 15
    
      end

      tab.show_lines =:none
      tab.show_headings = false
      tab.orientation = :center
      tab.position = :center
      tab.shade_color = Color::RGB.new(225, 238, 245)
      #tab.line_color = vccColor

      tab.data.replace data  
      tab.text_color = Color::RGB::Black
    
      tab.render_on(pdf)  
   
    end
  
    pdf.select_font("Helvetica" , { :encondig => "WinAnsiEnconding" } )
    pdf.fill_color  Color::RGB::Black
    pdf.text " ", :font_size => 5

  end
  
  

end