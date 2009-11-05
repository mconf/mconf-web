class AgendaEntry < ActiveRecord::Base
  belongs_to :agenda
  
  #acts_as_content :reflection => :agenda
  
  #minimum duration IN MINUTES of an agenda entry that is NOT excluded from recording 
  MINUTES_NOT_EXCLUDED =  30
  
end
