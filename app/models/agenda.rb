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

  def agenda_entries_for_day(i)
    all_entries = []
    for entry in agenda_entries
      if entry.start_time > (event.start_date + i.day).to_date && entry.start_time < (event.start_date + 1.day + i.day).to_date
        all_entries << entry
      end
    end
    all_entries
  end
  
end
