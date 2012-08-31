# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

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
  #TODO Rails 3. Conflicts with station inquirer ("ORDER BY clause should come after UNION not before: SELECT  * FROM")
  acts_as_tree #:order => 'updated_at ASC'

  scope :public, lambda { |arg|
    join(:space).where('public = ?', true)
  }
  scope :not_events, lambda {
    where(:event_id =>  nil)
  }

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
      nil
    else
      author_type.constantize.find_by_id author_id
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
end
