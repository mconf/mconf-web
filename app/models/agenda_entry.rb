class AgendaEntry < ActiveRecord::Base
  belongs_to :agenda
  
  #acts_as_content :reflection => :agenda
  
end
