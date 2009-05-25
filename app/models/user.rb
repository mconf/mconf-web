require 'digest/sha1'
class User < ActiveRecord::Base
  apply_simple_captcha :message => "image and text were different"
  # LoginAndPassword Authentication:
  acts_as_agent :activation => true

  # CAS Authentication::
  #
  #acts_as_agent :authentication => [:cas ],
  #              :cas_filter => {
  #                 :cas_base_url => "https://kimi.dit.upm.es/cas/"
  #              }

  validates_presence_of :email

  acts_as_stage
  acts_as_taggable

  has_one :profile
  has_many :events, :as => :author
  has_many :posts, :as => :author
  has_many :memberships, :dependent => :destroy
  has_many :groups, :through => :memberships
  
  attr_accessible :captcha, :captcha_key, :authenticate_with_captcha
  attr_accessible :email2, :email3 , :machine_ids
  attr_accessible :superuser, :disabled
  
  
 is_indexed :fields => ['login','email'],
:include => [#{:class_name => 'Profile',:field => 'name',:as => 'profile_name'},
             {:class_name => 'Profile',:field => 'organization',:as => 'profile_organization'},
             #{:class_name => 'Profile',:field => 'lastname',:as => 'profile_lastname'}
],
:concatenate => [{:class_name => 'Tag',:field => 'name',:as => 'tags',
:association_sql => "LEFT OUTER JOIN taggings ON (users.`id` = taggings.`taggable_id` AND taggings.`taggable_type` = 'User') LEFT OUTER JOIN tags ON (tags.`id` = taggings.`tag_id`)"
}]

alias_attribute :full_name, :login
alias_attribute :name, :login

def <=>(user)
  self.name <=> user.name
end

def organization
  profile ? profile.organization : "Organization"
end

def city
  profile ? profile.city : "City"
end

def country
  profile ? profile.country : "Country"
end

def logo
  profile && profile.logo
end

  def spaces
    stages.select{ |s| s.is_a?(Space) }.sort_by{ |s| s.name }
  end

  def other_public_spaces
    Space.public.all(:order => :name) - spaces
  end

#this method let's the user to login with his e-mail
  def self.authenticate_with_login_and_password(login, password)
    u = find_by_login(login) # need to get the salt
    unless u
      u = find_by_email(login)
    end
    u && u.password_authenticated?(password) ? u : nil
  end
  
 
 def self.atom_parser(data)

    e = Atom::Entry.parse(data)
    user = {}
    user[:login] = e.title.to_s
    user[:password] = e.get_elem(e.to_xml, "http://sir.dit.upm.es/schema", "password").text
    user[:password_confirmation] = user[:password]
    e.get_elems(e.to_xml, "http://schemas.google.com/g/2005", "email").each do |email|
        user[:email] = email.attributes['address']
    end
    t = []
    e.categories.each do |c|
      unless c.scheme
        t << c.term
      end
    end
    tags = t.join(sep=",")

    { :user => user, :tags => tags}     
  end

  def local_affordances
    Array(ActiveRecord::Authorization::Affordance.new(self, [ :manage, :message ])) + 
    self.fellows.map{|f| ActiveRecord::Authorization::Affordance.new(f, [:read, :profile])}
  end
 
end
