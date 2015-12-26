# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class Post < ActiveRecord::Base

  include PublicActivity::Common

  belongs_to :space
  belongs_to :author, :polymorphic => true

  acts_as_tree #:order => 'updated_at ASC'

  scope :public_posts, -> { join(:space).where('public = ?', true) }

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
    User.with_disabled.where(:id => author_id).first
  end

  def space
    Space.with_disabled.where(:id => space_id).first
  end

  # This method return the 3 last comment of a thread if the thread has more than 3 comments.
  # If not, return the parent post and their comments
  def three_last_comment()
    return self.children.last(3)
  end

  def new_activity(key, user)
    params = { username: user.name, user_id: user.id }

    if key.to_s == 'update'
      # Don't create activity if model was updated and nothing changed
      attr_changed = previous_changes.except('updated_at').keys
      return unless attr_changed.present?

      params.merge!(changed_attributes: attr_changed)
    end

    create_activity key, owner: space, recipient: user, parameters: params
  end

end
