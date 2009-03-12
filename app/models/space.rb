class Space < ActiveRecord::Base
  has_many :posts,  :dependent => :destroy
  has_many :events, :dependent => :destroy
  has_many :groups, :dependent => :destroy

  acts_as_resource :param => :name
  acts_as_container
  acts_as_logotypable

  validates_presence_of :name, :description
  validates_uniqueness_of :name
  
  after_create { |space| 
    group = Group.new(:name => space.emailize_name, :space_id => space.id)
    group.users << space.get_users_with_role("admin")
    group.users << space.get_users_with_role("user")
    group.save
  }

  def emailize_name
    self.name = self.name.gsub(" ", "")
  end

  # Users that belong to this space  
  # 
  # Options:
  # role:: Name of the role actors play in this space
  def users(options = {})
    if options[:role]
      actors.select{ |a| a.role.name == options[:role] }
    else
      actors
    end
  end
 
  # AtomPub
  def self.atom_parser(data)
    e = Atom::Entry.parse(data)

    space = {}
    space[:name] = e.title.to_s
    space[:description] = e.summary.to_s
    space[:deleted] = e.get_elem(e.to_xml, "http://schemas.google.com/g/2005", "deleted").text
    space[:parent_id] = e.get_elem(e.to_xml, "http://sir.dit.upm.es/schema", "parent_id").text

    visibility = e.get_elem(e.to_xml, "http://schemas.google.com/g/2005", "visibility").text
    space[:public] = visibility == "public"
  
    { :space => space }
  end
end
