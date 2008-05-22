class Space < ActiveRecord::Base
  acts_as_container
  
  validates_presence_of :name, :description
  #method to know the users that belong to this space
  def users
    actors
  end
  
  
  def manage_groups_by?(user)
 user.superuser || has_role_for?(user, :admin) || has_role_for?(user, :create_performances) 
 end
 
 
  def edit_by?(user)

    user.superuser || has_role_for?(user, :admin)
        
  end
  
  
  def add_users_by?(user)

    user.superuser || has_role_for?(user, :admin) || has_role_for?(user, :create_performances) 

  end
  
  #method to print an array of the user names
  #it is used to build a javascript array
  #so each name has to be between quotation marks and separated by commas
  def print_array_of_agents
    temp = ""
    for agen in actors
      temp = temp + "\"" + agen.login + "\", "
    end
    temp.chop.chop   #removes the last character, in this case the last space and the last comma
  end
  
  
  #returns an array of users with the role id in this space
  def agents_with_role(id)
    array = []
    for perfor in container_performances
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
    for perfor in container_performances 
      role = CMS::Role.find(perfor.role_id)
      if role.type == nil
        perfor.destroy
      end
    end    
  end
  
  
  #returns a javascript array of all users of this space
  def print_array_of_all_users
    actors.map{ |a| "\"#{ a.login }\"" }.join(", ")
  end
 
end