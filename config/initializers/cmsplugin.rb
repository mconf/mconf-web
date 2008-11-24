# Modifications of CMSplugin
#
# Load the class first, then add modifications to it

Entry

class Entry
  acts_as_tree :order => "title"
  acts_as_taggable

  before_destroy { |entry| 
    entry.children.map { |entry_children|  entry_children.content.destroy}
  }

  after_create { |entry|
    if entry.parent_id != nil
      entry.parent.update_attribute(:updated_at , Time.now)
   end
  }

  after_update { |entry| 
    entry.children.map { |entry_children| 
      entry_children.update_attribute(:public_read, entry.public_read) 
    } 
  }
  
  def authorizes?(agent, actions)
    return true if agent.superuser || self.has_role_for?(agent, :admin)
    
     actions = Array(actions)
    if self.agent
      if actions.delete(:edit)
        return true if self.agent == agent 
      end
      if actions.delete(:delete)
        return true if self.agent == agent 
      end
    end
    false
  end
end

Tag

class Tag
  def self.cloud(args = {})
    find(:all, :select => 'tags.* ,count(*) as popularity',
    :limit => args[:limit] || 30,
    :joins => "JOIN taggings ON taggings.tag_id = tags.id",
    :conditions => args[:conditions],
    :group => "taggings.tag_id",
    :order => "id")
  end
end

AnonymousAgent

class AnonymousAgent
  def superuser
    false
  end

  def login
    "Anonymous"
  end
end


