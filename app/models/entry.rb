require "#{RAILS_ROOT}/vendor/plugins/cmsplugin/app/models/entry"
class Entry
  acts_as_tree :order => "title"
  acts_as_taggable

before_destroy { |entry| entry.children.map { |entry_children|  entry_children.content.destroy}}

after_create {|entry|if entry.parent_id != nil
 entry.parent.update_attribute(:updated_at , Time.now)
 end
}

after_update { |entry| entry.children.map {|entry_children| entry_children.update_attribute(:public_read, entry.public_read) } }

  def authorizes?(agent, actions)
    return true if agent.superuser || self.has_role_for?(agent, :admin)
    
     actions = Array(actions)

    if actions.delete(:edit)
      return true if self.agent == agent 
    end
    
    false
  end
  
end
