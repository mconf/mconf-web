class Agenda < ActiveRecord::Base
  belongs_to :event
  has_many :agenda_entries
  has_many :agenda_record_entries
  has_many :attachments, :through => :agenda_entries, :dependent => :destroy
  has_one :attachment, :dependent => :destroy
  accepts_nested_attributes_for :attachment
  
  #acts_as_container :content => :agenda_entries
  #acts_as_content :reflection => :event

  # Fill attachments event and space
  before_validation do |agenda|
    agenda.attachment.space  ||= agenda.event.space
    agenda.attachment.event  ||= agenda.event
  end

end
