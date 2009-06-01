# Modifications of CMSplugin
#
# Load the class first, then add modifications to it


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

  # Destroy Space group memberships before leaving the Space
  before_destroy { |p|
    if p.stage.is_a?(Space) && p.agent.is_a?(User)
      p.agent.memberships.select{ |m| m.group && m.group.space == p.stage }.map(&:destroy)
    end
  }

  # Destroy Space admission after leaving the Space
  after_destroy { |p|
    if p.stage.is_a?(Space) && p.agent.is_a?(User)
      p.stage.admissions.find_by_candidate_id_and_candidate_type(p.agent.id, p.agent.class.base_class.to_s).destroy
    end
  }
  
end

Logo

class Logo
  has_attachment :max_size => 2.megabyte,
                 :storage => :file_system,
                 :content_type => :image,
                 :thumbnails => {
                    '256' => '256x256>',
                    '128' => '128x128>',
                    '96' => '96x96>',
                    '72' => '72x72>',
                    '64' => '64x64>',
                    '48' => '48x48>',
                    '32' => '32x32>',
                    '22' => '22x22>',
                    '16' => '16x16>',
                    'h64' => 'x64',
                    'front' => '188x143!'
                 }
end

# In SIR authorization, users that are superusers are gods
# This module allows implementing this feature in all classes that implement authorizes?
module ActiveRecord::Authorization::InstanceMethods
  alias authorizes_without_superuser authorizes?

  def authorizes_with_superuser(action, options = {})
    return true if options[:to] && options[:to].superuser

    authorizes_without_superuser(action, options)
  end

  alias authorizes? authorizes_with_superuser
end
