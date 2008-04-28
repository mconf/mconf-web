class Participant < ActiveRecord::Base
  belongs_to :events
  belongs_to :machines
  
  #array of types of service
  PARTICIPANT_ROLES = [
   ["Interactive", "interactive"],
   ["FlowServer", "mcu"]].freeze  #makes this array constant

    #array of forward error correcting
    FEC = [
      ["None",0],
      ["10%",10],
      ["25%",25],
      ["50%",50],
      ["100%",100]].freeze

    NUMBER_OF_SITES_PER_PARTICIPANT = 10.0
    
end
