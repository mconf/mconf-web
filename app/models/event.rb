class Event < ActiveRecord::Base
  belongs_to :space
  belongs_to :author, :polymorphic => true

  acts_as_resource :per_page => 10
  acts_as_content :reflection => :space
  acts_as_taggable
  alias_attribute :title, :name
  validates_presence_of :name, :start_date , :end_date,
                          :message => "must be specified"

  # Attributes for jQuery selectors
  attr_accessor :start_hour
  attr_accessor :end_hour
  
  is_indexed :fields => ['name','description','place','start_date','end_date'],
             :concatenate => [{:class_name => 'Tag',:field => 'name',:as => 'tags',
             :association_sql => "LEFT OUTER JOIN taggings ON (events.`id` = taggings.`taggable_id` AND taggings.`taggable_type` = 'Event') LEFT OUTER JOIN tags ON (tags.`id` = taggings.`tag_id`)"
             }]
  
  before_validation do |event|
    if event.start_hour.present?
      event.start_date += ( Time.parse(event.start_hour) - Time.today )
      event.end_date   += ( Time.parse(event.end_hour)   - Time.today )
    end
  end
      
  def validate
    unless self.start_date < self.end_date
      errors.add_to_base("The event start date must be previous than the event end date ")
    end
#    unless self.start_date.future? 
#      errors.add_to_base("The event start date should be a future date  ")
#    end
  end
end
