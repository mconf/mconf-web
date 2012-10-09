# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class PrivateMessage < ActiveRecord::Base
  belongs_to :sender,  :class_name => "User"
  belongs_to :receiver, :class_name => "User"
  attr_accessor :users_tokens
  acts_as_resource :per_page => 10
  validates_acceptance_of :users_tokens, :unless => Proc.new { |pm| pm.receiver_id } 
  validates_presence_of :receiver_id , :title, :body,
                          :message => "must be specified"

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

# Commented because it causes an error when a user is joining to a space and sends private messages to space admins

#  def validate
#    unless User.find(self.sender_id).fellows.include?(User.find(self.receiver_id))
#      errors.add(:receiver_id, "Receiver and sender have to share one or more spaces.")
#    end
#  end


# Couldnt be destroyed to mantain the thread history
=begin
  after_update :after_update_method
  def after_update_method
    self.destroy if self.deleted_by_sender && self.deleted_by_receiver
  end
=end
end
