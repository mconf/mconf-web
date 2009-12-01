class AgendaEntry < ActiveRecord::Base
  belongs_to :agenda

  has_one :attachment, :dependent => :destroy
  accepts_nested_attributes_for :attachment
  
  acts_as_stage
  
  #acts_as_content :reflection => :agenda
  
  #minimum duration IN MINUTES of an agenda entry that is NOT excluded from recording 
  MINUTES_NOT_EXCLUDED =  30
  
  # Fill attachments event and space
  before_validation do |agenda_entry|
    if (agenda_entry.attachment != nil) then
      agenda_entry.attachment.space  ||= agenda_entry.agenda.event.space
      agenda_entry.attachment.event  ||= agenda_entry.agenda.event
      agenda_entry.attachment.author ||= agenda_entry.agenda.event.author 
    end
  end
  
end
