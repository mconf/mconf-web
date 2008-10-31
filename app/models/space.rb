class Space < ActiveRecord::Base
  acts_as_container
  
  has_many :groups, :dependent => :destroy
  has_one :logotype , :as => 'logotypable'
  validates_presence_of :name, :description
  validates_uniqueness_of :name
  
  def to_param
    name
  end
  
  after_create { |space| 
  group = Group.new(:name => space.emailize_name, :space_id => space.id)
  group.users << space.get_users_with_role("admin")
  group.users << space.get_users_with_role("user")
  group.save
  }
  
  before_destroy { |space| space.logotype.destroy if space.logotype}
  
  def emailize_name
    self.name = self.name.gsub(" ", "")
  end
  
  #method that returns the events of the space
  def events
    array_all_entries = container_entries.collect
    array_events = Array.new
    for entry in array_all_entries
      if entry.content_type == "Event"
        array_events << Event.find(entry.content_id)
      end
    end
    
    return array_events
    
  end
  
  
  #method to know the users that belong to this space  
  def users
    actors
  end
 
  def get_users_with_role(role)
    array_users = []
    array_performances = Performance.find_all_by_container_id(self, :conditions=>["role_id = ?", Role.find_by_name(role)])
    for perfor in array_performances
      array_users << User.find(perfor.agent_id)
    end
    return array_users
  end
  
  def authorizes?(agent, actions)
    return true if agent.superuser || has_role_for?(agent, :admin)

    Array(actions).each do |action|
      return false unless self.has_role_for?(agent, action)
    end
    true
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
      role = Role.find(perfor.role_id)
      if role.type == nil
        perfor.destroy
      end
    end    
  end
  
  
  #returns a javascript array of all users of this space
  def print_array_of_all_users
    actors.map{ |a| "\"#{ a.login }\"" }.join(", ")
  end
 
  
  def self.compone_array_spaces(user)
    if user==:false
      #if the user is not logged in, we show all the public spaces
      array_spaces = []       
      array_spaces += Space.find_all_by_public(true).flatten.collect {|r| [ r.name, r.name ]}
      
      return array_spaces
    end
    array_spaces = []    
    if user.superuser==true
      array_spaces += Space.find(:all).collect {|r| [ r.name, r.name ]}
    else
      if !user.stages.include?(Space.find(1))
        array_spaces << Space.find_all_by_id(1).flatten.collect {|r| [ r.name, r.name ]}.flatten
      end
      array_spaces += user.stages.collect {|r| [ r.name, r.name ]}
    end
    #add the public spaces
    public_spaces = Space.find_all_by_public(true)
    if public_spaces !=nil
      for spacepublic in public_spaces
        if user.superuser==false && !user.stages.include?(spacepublic) && spacepublic.id!=1
          array_spaces << Array[spacepublic.name + "(*)", spacepublic.name]
        end
      end
    end
    return array_spaces
  end

  def self.atom_parser(data)

    e = Atom::Entry.parse(data)
    space = {}
    space[:name] = e.title.to_s
    space[:description] = e.summary.to_s
    space[:deleted] = e.get_elem(e.to_xml, "http://schemas.google.com/g/2005", "deleted").text
    space[:parent_id] = e.get_elem(e.to_xml, "http://sir.dit.upm.es/schema", "parent_id").text
    visibility = e.get_elem(e.to_xml, "http://schemas.google.com/g/2005", "visibility").text
    
    if visibility == "public"
    space[:public] = true
  else
    space[:public] = false
  end
  
    { :space => space}     
  end
end
