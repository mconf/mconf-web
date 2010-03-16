# Copyright 2008-2010 Universidad Politécnica de Madrid and Agora Systems S.A.
#
# This file is part of VCC (Virtual Conference Center).
#
# VCC is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# VCC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with VCC.  If not, see <http://www.gnu.org/licenses/>.

require 'digest/sha1'
class User < ActiveRecord::Base
  apply_simple_captcha :message => "image and text were different"
  # LoginAndPassword Authentication:
  acts_as_agent :activation => true,
                :openid_server => true

  validates_presence_of :email

  acts_as_stage
  acts_as_taggable :container => false
  acts_as_resource :param => :login

  has_one :profile, :dependent => :destroy
  has_many :events, :as => :author
  has_many :posts, :as => :author
  has_many :memberships, :dependent => :destroy
  has_many :groups, :through => :memberships
  
  attr_accessible :captcha, :captcha_key, :authenticate_with_captcha
  attr_accessible :email2, :email3 , :machine_ids
  attr_accessible :timezone
  attr_accessible :expanded_post, :notification
  attr_accessible :chat_activation
  
  is_indexed :fields => ['login','email'],
             :include => [ #{:class_name => 'Profile',:field => 'name',:as => 'profile_name'},
             { :class_name => 'Profile',:field => 'organization',:as => 'profile_organization'},
            #{ :class_name => 'Profile',:field => 'lastname',:as => 'profile_lastname'}
            ],

             :concatenate => [ { :class_name => 'Tag',:field => 'name',:as => 'tags',
                                 :association_sql => "LEFT OUTER JOIN taggings ON (users.`id` = taggings.`taggable_id` AND taggings.`taggable_type` = 'User') LEFT OUTER JOIN tags ON (tags.`id` = taggings.`tag_id`)"
             }]


  default_scope :conditions => {:disabled => false}

  #constant for the notification attribute
  NOTIFICATION_VIA_EMAIL = 1
  NOTIFICATION_VIA_PM = 2

  # Profile

  def profile!
    if profile.blank?
      self.create_profile
    else
      profile
    end
  end

  delegate :full_name, :logo, :organization, :city, :country, :to => :profile!
  alias_attribute :name, :full_name
  alias_attribute :title, :full_name

  # Full name must go to the profile, but it is provided by the user in signing up
  # so we have to temporally cache it until the user is created; :_full_name
  attr_accessor :_full_name
  attr_accessible :_full_name
  has_permalink :_full_name, :login

  after_create do |user|
    user.create_profile :full_name => user._full_name
  end

  def self.find_with_disabled *args
    self.with_exclusive_scope { find(*args) }
  end

  def <=>(user)
    self.login <=> user.login
  end

  def spaces
    stages.select{ |s| s.is_a?(Space) && !s.disabled? }.sort_by{ |s| s.name }
  end

  def other_public_spaces
    Space.public.all(:order => :name) - spaces
  end

  #this method let's the user to login with his e-mail
  def self.authenticate_with_login_and_password(login, password)
    u = if login =~ /@/
          if login =~ /(.*)@#{ Site.current.presence_domain }$/
            find_by_login $1
          else
            find_by_email login
          end
        else
          find_by_login login
        end

    u && u.password_authenticated?(password) ? u : nil
  end
  
  after_update { |user|
      if user.email_changed? 
        user.groups.each do |group|
          if group.mailing_list.present?
            delete_list(group,group.mailing_list)
            group.mail_list_archive
            copy_list(group,group.mailing_list)
          end
        end
        Group.request_list_update
      end
  }
  
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


  def disable
    self.update_attribute(:disabled,true)
    self.agent_performances.each(&:destroy)
  end
  
  def enable
    self.update_attribute(:disabled,false)
  end

  # Use profile.logo for users logo when present
  def logo_image_path_with_logo(options = {})
    logo.present? ?
      logo.logo_image_path(options) :
      logo_image_path_without_logo(options)
  end
  alias_method_chain :logo_image_path, :logo

  def public_fellows
    fellows
  end
  
  def private_fellows
    stages(:type => "Space").select{|x| x.public == false}.map(&:actors).flatten.compact.uniq.sort{ |x, y| x.name <=> y.name }
  end

  authorizing do |agent, permission|
    false if disabled?
  end

  authorizing do |agent, permission|
    true if agent == self
  end
end
