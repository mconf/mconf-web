class Agenda < ActiveRecord::Base
  belongs_to :event
  has_many :agenda_entries
  has_many :agenda_record_entries
  has_many :attachments, :through => :agenda_entries
  
  #acts_as_container :content => :agenda_entries
  #acts_as_content :reflection => :event
  
end
