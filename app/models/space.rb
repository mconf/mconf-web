class Space < ActiveRecord::Base
  acts_as_container
  
  
  #method to know the users that belong to this space
  def users
    agents
  end
  
  #method to print an array of the user names
  #it is used to build a javascript array
  #so each name has to be between quotation marks and separated by commas
  def print_array_of_agents
    temp = ""
    for agen in agents
      temp = temp + "\"" + agen.login + "\", "
    end
    temp.chop.chop   #removes the last character, in this case the last space and the last comma
  end
  
  #returns an array of users with the role id in this space
  def agents_with_role(id)
    array = []
    for perfor in performances
      if perfor.role_id==id
         array << User.find_by_id(perfor.agent_id)
      end
    end
    return array
  end
  
  #returns a javascript array with the login of the users
  def self.to_js_array(array)
    res = "[ "
    for user in array
      res = res + "\"" + user.login + "\","
    end
    res = res.chop #remove the last comma
    res = res + " ]"
  end
  
  #method to delete the performances, but not the groups (that are done with performances)
  def delete_performances
    for perfor in performances 
      role = CMS::Role.find(perfor.role_id)
      if role.type == nil
        perfor.destroy
      end
    end    
  end
end