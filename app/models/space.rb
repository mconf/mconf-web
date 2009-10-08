class Space < ActiveRecord::Base
  has_many :posts,  :dependent => :destroy
  has_many :events, :dependent => :destroy
  has_many :groups, :dependent => :destroy
  has_many :news, :dependent => :destroy

  has_many :event_invitations,
           :dependent => :destroy,
           :as => :group
                 
  has_permalink :name
  acts_as_resource :param => :permalink
  acts_as_container :sources => true
  acts_as_stage
  attr_accessor :mailing_list
  has_logo

  validates_presence_of :name, :description
  validates_uniqueness_of :name
  
  #after_create { |space|
      #group = Group.new(:name => space.emailize_name, :space_id => space.id, :mailing_list => space.mailing_list)
      #group.users << space.users(:role => "admin")
      #group.users << space.users(:role => "user")
      #group.save
  #}

  named_scope :public, lambda {
    { :conditions => { :public => true } }
  }

  default_scope :conditions => {:disabled => false}
  
  def self.find_with_disabled *args
    self.with_exclusive_scope { find(*args) }
  end

  def self.find_with_disabled_and_param *args
    self.with_exclusive_scope { find_with_param(*args) }
  end

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

  def disable
    self.update_attribute(:disabled,true)
  end

  def enable
    self.update_attribute(:disabled,false)
  end

  # There are previous authorization rules because of the stage
  # See acts_as_stage documentation
  authorizing do |agent, permission|
    if ! self.public?
      false
    else
      case permission
      when :read, [ :read, :content ], [ :read, :performance ]
        true
      else
        false
      end
    end
  end
end
