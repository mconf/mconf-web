class Event < ActiveRecord::Base
  belongs_to :space
  belongs_to :author, :polymorphic => true

  acts_as_resource :per_page => 10
  acts_as_content :reflection => :space
  acts_as_taggable
  alias_attribute :title, :name
  validates_presence_of :name, :start_date , :end_date,
                          :message => "must be specified"

  
begin  
  def validate
    unless self.start_date < self.end_date
      errors.add_to_base("The event start date must be previous than the event end date ")
    end
    unless self.start_date.future? 
      errors.add_to_base("The event start date should be a future date  ")
    end
  end
end

end
