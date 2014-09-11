# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class PrivateMessage < ActiveRecord::Base
  include PublicActivity::Common

  belongs_to :sender,  :class_name => "User"
  belongs_to :receiver, :class_name => "User"
  attr_accessor :users_tokens
  validates :users_tokens, :acceptance => true, :unless => Proc.new { |pm| pm.receiver_id }
  validates :receiver_id, :title, :body, :presence => true

  after_create :new_activity

  scope :inbox, lambda{ |user|
    user_id = case user
              when User
                user.id
              else
                user
              end
    where(:deleted_by_receiver => false, :receiver_id => user_id).order("created_at DESC")
  }

  scope :sent, lambda{ |user|
    user_id = case user
              when User
                user.id
              else
                user
              end
    where(:deleted_by_sender => false, :sender_id => user_id).order("created_at DESC")
  }
  
  scope :previous, lambda { |message|
    previous = []
    while message.parent_id
      message = PrivateMessage.find(message.parent_id)
      previous << message
    end
    previous
  }

  # Creates both sender and receiver acitivies
  def new_activity
    create_activity :sent, :owner => sender, :parameters => {:receiver_name => receiver.name}
    create_activity :received, :owner => receiver, :parameters => {:sender_name => sender.name, :digest => receiver.receive_digest}
  end

end
