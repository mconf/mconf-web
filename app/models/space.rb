class Space < ActiveRecord::Base
  acts_as_container
  
  
  #method to know the users that belong to this space
  def users
    agents
  end
end