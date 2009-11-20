class Event < ActiveRecord::Base
  belongs_to :space
  belongs_to :author, :polymorphic => true
  has_many :posts
  has_many :participants
  has_many :event_invitations, :dependent => :destroy
  has_many :attachments, :dependent => :destroy
  has_one :agenda
  
  has_logo :class_name => "EventLogo"
  
  acts_as_resource :per_page => 10
  acts_as_content :reflection => :space
  acts_as_taggable
  acts_as_stage
  acts_as_container :content => :agenda
  alias_attribute :title, :name
  validates_presence_of :name, :start_date , :end_date,
                          :message => "must be specified"
  
  # Attributes for jQuery selectors
  attr_accessor :start_hour
  attr_accessor :end_hour
  attr_accessor :mails
  attr_accessor :ids
  attr_accessor :invite_msg
  attr_accessor :external_streaming_url
  
  is_indexed :fields => ['name','description','place','start_date','end_date'],
             :include =>[{:class_name => 'Tag',
                          :field => 'name',
                          :as => 'tags',
                          :association_sql => "LEFT OUTER JOIN taggings ON (events.`id` = taggings.`taggable_id` AND taggings.`taggable_type` = 'Event') LEFT OUTER JOIN tags ON (tags.`id` = taggings.`tag_id`)"},
  {:class_name => 'User',
                               :field => 'login',
                               :as => 'login_user',
                               :association_sql => "LEFT OUTER JOIN users ON (events.`author_id` = users.`id` AND events.`author_type` = 'User') "}
  ]
  
  before_validation do |event|
    if event.start_hour.present?
      event.start_date += ( Time.parse(event.start_hour) - Time.now.midnight )
      event.end_date   += ( Time.parse(event.end_hour)   - Time.now.midnight )
    end
  end
  
  after_create do |event|
    #create an empty agenda
    event.agenda = Agenda.create
  end
  
  after_save do |event|
    #fisrt of all we remove the emails that already has an invitation for this event (not to spam them)
    if event.mails
      mails_to_invite = event.mails.split(/[\r,]/).map(&:strip) - event.event_invitations.map{|ei| ei.email}
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
  end
  
  def author
    User.find_with_disabled(author_id)
  end
  
  def space
    Space.find_with_disabled(space_id)
  end      
  
  def organizers
    actors
  end
  
  #return the number of days of this event duration
  def days
    end_date.day - start_date.day + 1
  end
  
  
  def validate
    if self.start_date.nil? || self.end_date.nil? 
      errors.add_to_base("The event needs start date and end date ")
    else
      unless self.start_date < self.end_date
        errors.add_to_base("The event start date must be previous than the event end date ")
      end  
    end
    if self.marte_event? && ! self.marte_room?
      #check connectivity with Marte
      begin
        MarteRoom.find(:all)
      rescue => e
        errors.add_to_base("Could not create virtual conference")
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
    if event.marte_event? && event.marte_room?
      begin
        MarteRoom.find(event.id).destroy
      rescue
      end
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
end
