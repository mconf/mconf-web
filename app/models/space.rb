class Space < ActiveRecord::Base
  has_many :posts,  :dependent => :destroy
  has_many :events, :dependent => :destroy
  has_many :groups, :dependent => :destroy
  has_many :news, :dependent => :destroy

  acts_as_resource :param => :name
  acts_as_container
  acts_as_stage
  has_logo

  validates_presence_of :name, :description
  validates_uniqueness_of :name
  
  after_create { |space| 
    group = Group.new(:name => space.emailize_name, :space_id => space.id)
#    group.users << space.get_users_with_role("admin")
#    group.users << space.get_users_with_role("user")
    group.save
  }

  def emailize_name
    self.name.gsub(" ", "")
  end

  # Users that belong to this space  
  # 
  # Options:
  # role:: Name of the role actors play in this space
  def users(options = {})
    if options[:role]
      stage_performances.select{ |p| p.role.name == options[:role] }.map(&:agent)
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

  def local_affordances
    affs = []
    if self.public?
      affs << ActiveRecord::Authorization::Affordance.new(Anyone.current, :read)
      affs << ActiveRecord::Authorization::Affordance.new(Anyone.current, [ :read, :content ])
      affs << ActiveRecord::Authorization::Affordance.new(Anyone.current, [ :read, :performance ])
      affs << ActiveRecord::Authorization::Affordance.new(Anyone.current, [ :create, :performance ])
    end

    affs
  end
end
