class AgendaRecordEntry < ActiveRecord::Base
  belongs_to :agenda
  has_many :attachments
  
  #act_as_content :reflection => :agenda
  
end
