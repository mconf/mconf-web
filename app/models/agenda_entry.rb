class AgendaEntry < ActiveRecord::Base
  belongs_to :agenda
  
  #acts_as_content :reflection => :agenda
  
  #minimum duration IN SECONDS of an agenda entry that is excluded from recording
  MIN_TO_EXCLUDE =  1800
  
end
