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

class Space < ActiveRecord::Base
  has_many :posts,  :dependent => :destroy
  has_many :events, :dependent => :destroy
  has_many :groups, :dependent => :destroy
  has_many :news, :dependent => :destroy
  has_many :attachments, :dependent => :destroy
  has_many :tags, :dependent => :destroy, :as => :container
           
  has_permalink :name, :update=>true
  
  acts_as_resource :param => :permalink
  acts_as_container :contents => [ :news, :posts, :attachments, :events ],
                    :sources => true
  acts_as_stage
  attr_accessor :mailing_list_for_group
  attr_accessor :invitation_ids
  attr_accessor :invitation_mails
  attr_accessor :invite_msg
  attr_accessor :inviter_id
  attr_accessor :invitations_role_id
  has_logo

  validates_presence_of :name, :description
  validates_uniqueness_of :name
  
  #after_create { |space|
      #group = Group.new(:name => space.emailize_name, :space_id => space.id, :mailing_list => space.mailing_list)
      #group.users << space.users(:role => "admin")
      #group.users << space.users(:role => "user")
      #group.save
  #}
  
  after_save do |space|
    if space.invitation_mails
      mails_to_invite = space.invitation_mails.split(/[\r,]/).map(&:strip)
      mails_to_invite.map { |email|      
        params =  {:role_id => space.invitations_role_id.to_s, :email => email, :comment => space.invite_msg}
        i = space.invitations.build params
        i.introducer = User.find(space.inviter_id)
        i
      }.each(&:save)
    end
    if space.invitation_ids
      space.invitation_ids.map { |user_id|
        user = User.find(user_id)
        params = {:role_id => space.invitations_role_id.to_s, :email => user.email, :comment => space.invite_msg}
        i = space.invitations.build params
        i.introducer = User.find(space.inviter_id)
        i
      }.each(&:save)
    end
  end

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
    for group in self.groups
      Group.disable_list(group,group.mailing_list)
    end
  end

  def enable
    self.update_attribute(:disabled,false)
    for group in self.groups
      Group.enable_list(group,group.mailing_list)
    end
  end

  # There are previous authorization rules because of the stage
  # See acts_as_stage documentation
  authorizing do |agent, permission|
    if self.public? && [ :read, [ :read, :content ], [ :read, :performance ] ].include?(permission)
      true
    end
  end
end
