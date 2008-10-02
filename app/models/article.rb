class Article < ActiveRecord::Base
  acts_as_content 
  acts_as_ferret :fields => {  
    :title=> {:store => :yes} ,
    :description=> {:store => :yes} ,
    :text=> {:store => :yes} ,
    :tags=> {:store => :yes} ,
  }
  
    acts_as_taggable
 # is_indexed :fields => ['text','title']#,
  
#  :include => [{:class_name => 'Entry', :field => 'title', :association_sql => "" }],
 # :include => [{:class_name => 'Tag', :field => 'name', :association_sql => "JOIN taggings ON taggings.tag_id = tags.id" }]
  


  
  
  def description    
    @entry = Entry.find_by_content_type_and_content_id("Article", self.id)
    return @entry.description
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
