class Article < ActiveRecord::Base
  acts_as_content 
  acts_as_ferret :fields => {  
    :title=> {:store => :yes} ,
    :description=> {:store => :yes} ,
    :text=> {:store => :yes} ,
    :tags=> {:store => :yes} ,
  }
  
  #is_indexed :fields => ['text']

  def title    
    @entry = Entry.find_by_content_type_and_content_id("XhtmlText", self.id)
    return @entry.title
  end
  
  def description    
    @entry = Entry.find_by_content_type_and_content_id("XhtmlText", self.id)
    return @entry.description
  end
  
  
  def tags
    @entry = Entry.find_by_content_type_and_content_id("XhtmlText", self.id)
    return @entry.tag_list.collect {|tag| tag} if @entry.tag_list
  end
  
   def authorizes?(agent, actions)
    return true if agent.superuser || self.entry.has_role_for?(agent, :admin)
    
     actions = Array(actions)

    if actions.delete(:edit)
      return true if self.entry.agent == agent 
    end
    
    false
  end
end
