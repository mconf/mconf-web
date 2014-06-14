# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class Post < ActiveRecord::Base

  include PublicActivity::Common

  belongs_to :space
  belongs_to :author, :polymorphic => true

  acts_as_tree #:order => 'updated_at ASC'

  scope :public, lambda { |arg|
    join(:space).where('public = ?', true)
  }

  validates_presence_of :title, :unless => Proc.new { |post| post.parent.present? }
  validates_presence_of :text

  # Update parent Posts when commenting to it
  after_save do |post|
    post.parent.try(:touch)
  end

  def post_title
    title || parent.title
  end

  def author
    case author_type
    when User
      User.find_by_id_with_disabled(author_id)
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
    return Post.find(:all, :conditions => {:space_id => space, :parent_id => nil}, :order => "updated_at DESC", :limit => 4)
  end

  def new_activity key, user
    create_activity key, :owner => space, :parameters => { :username => user.name, :user_id  => user.id}
  end

end
