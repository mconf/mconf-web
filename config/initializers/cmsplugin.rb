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

SingularAgent

class SingularAgent
  def superuser
    false
  end
  alias superuser? superuser

  def profile
    nil
  end

  def email
    ""
  end

  def <=>(agent)
    self.name <=> agent.name
  end

  def disabled
    false
  end

  def active?
    true
  end
end

Performance

class Performance

  after_create {|perfor|
    user = perfor.agent
    if perfor.stage.is_a?(Space) && user.is_a?(User)
    space = perfor.stage
    role = perfor.role
    group = Group.find_by_name(space.emailize_name)
    if group
    if (role == Role.find_by_name("Admin") || role == Role.find_by_name("User")) && !group.users.include?(user)
      user_ids = []
      group.users.each do |u|
        user_ids << "#{u.id}"
      end
      user_ids << "#{user.id}"
      
      group.update_attributes(:user_ids => user_ids)
    end
    end
    end
  }

  before_destroy {|perfor|
    user = perfor.agent
    if perfor.stage.is_a?(Space)
    space = perfor.stage
    group = Group.find_by_name(space.emailize_name)
    if group
      user_ids = []
      group.users.each do |u|
        user_ids << "#{u.id}"
      end
      user_ids.delete("#{user.id}")
      
      group.update_attributes(:user_ids => user_ids)  
      end
    end
  }
  
end

Invitation

class Invitation
  DELIMITER = (/,|;| /)

  validates_presence_of :stage_id, :stage_type, :role_id
end

# In SIR authorization, users that are superusers are gods
# This module allows implementing this feature in all classes that implement authorizes?
module SirAuthorizes
  class << self
    def included(base)
      base.class_eval do
        alias authorizes_without_superuser authorizes?
        def authorizes_with_superuser(agent, *args)
          return true if agent.superuser

          return true if self.respond_to?(:entry) &&
                         self.entry.agent == agent &&
                         self.entry.container.authorizes?(agent, [ :create, :Content ])

          authorizes_without_superuser(agent, *args)
        end
        alias authorizes? authorizes_with_superuser
      end
    end
  end
end

ActiveRecord::Stage::InstanceMethods.send :include, SirAuthorizes

