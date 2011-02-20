# -*- coding: utf-8 -*-
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

class Post < ActiveRecord::Base
  belongs_to :space
  belongs_to :author, :polymorphic => true
  has_many :post_attachments, :dependent => :destroy
  has_many :attachments, :through => :post_attachments

  belongs_to :event

  accepts_nested_attributes_for :attachments, :allow_destroy => true

  acts_as_resource :per_page => 10
  acts_as_content :reflection => :space
  acts_as_taggable
  acts_as_tree :order => 'updated_at ASC'

  scope :public, lambda { |arg|
    join(:space).where('public = ?', true)
  }
  scope :not_events, lambda {
    where(:event_id =>  nil)
  }


  # TODO is_indexed comes from Ultrasphinx
=begin
  is_indexed :fields => ['text','title','space_id','updated_at'],
             :include =>[{:class_name => 'Tag',
                          :field => 'name',
                          :as => 'tags',
                          :association_sql => "LEFT OUTER JOIN taggings ON (posts.`id` = taggings.`taggable_id` AND taggings.`taggable_type` = 'Post') LEFT OUTER JOIN tags ON (tags.`id` = taggings.`tag_id`)"},
                          {:class_name => 'User',
                               :field => 'login',
                               :as => 'login_user',
                               :association_sql => "LEFT OUTER JOIN users ON (posts.`author_id` = users.`id` AND posts.`author_type` = 'User') "}#,
                          #{:class_name => 'Profile',:field=> 'name',:as => 'name_user',:association_sql => "LEFT OUTER JOIN profiles ON (profiles.`user_id` = users.`id`)"},
                          #{:class_name => 'Profile',:field=> 'lastname',:as => 'lastname_user',:association_sql => "LEFT OUTER JOIN profiles ON (profiles.`user_id` = users.`id`)"}
                          ]

=end

  validates_presence_of :title, :unless => Proc.new { |post| post.parent.present? || post.event.present? }
  validates_presence_of :text, :if => Proc.new { |post| post.attachments.empty? && post.event.blank? }

  # Fill attachments author and space
  before_validation do |post|
    post.attachments.each do |a|
      a.space  ||= post.space
      a.author = post.author
    end
  end

  # Update parent Posts when commenting to it
  after_save do |post|
    post.parent.try(:touch)
  end

  def author
    case author_type
    when User
      User.find_with_disabled(author_id)
    when NilClass
      Anonymous.current
    else
      author_type.constantize.find author_id
    end
  end

  def space
    space_id.present? ?
      Space.find_with_disabled(space_id) :
      nil
  end

  # This method return the 3 last comment of a thread if the thread has more than 3 comments.
  # If not, return the parent post and their comments
  def three_last_comment()
    return self.children.last(3)
  end

  def self.last_news(space)
    return Post.not_events().find(:all, :conditions => {:space_id => space, :parent_id => nil}, :order => "updated_at DESC", :limit => 4)
  end

  # Author Permissions
  authorizing do |agent, permission|
    if author == agent &&
        ( permission == :update || permission == :delete ) &&
        space.authorize?([ :create, :content ], :to => agent)
      true
    end
  end
end
