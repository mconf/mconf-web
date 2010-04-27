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

class PrivateMessage < ActiveRecord::Base
  belongs_to :sender,  :class_name => "User"
  belongs_to :receiver, :class_name => "User"

  acts_as_resource :per_page => 10

  validates_presence_of :receiver_id , :title, :body,
                          :message => "must be specified"

  named_scope :inbox, lambda{ |user|
    user_id = case user
              when User
                user.id
              else
                user
              end
    {:conditions => {:deleted_by_receiver => false, :receiver_id => user_id},
     :order => "created_at DESC"}
  }
  
  named_scope :sent, lambda{ |user|
    user_id = case user
              when User
                user.id
              else
                user
              end
    {:conditions => {:deleted_by_sender => false, :sender_id => user_id},
    :order => "created_at DESC"}
  }

# Commented because it causes an error when a user is joining to a space and sends private messages to space admins
                          
#  def validate
#    unless User.find(self.sender_id).fellows.include?(User.find(self.receiver_id))
#      errors.add(:receiver_id, "Receiver and sender have to share one or more spaces.")
#    end
#  end


	def after_update
    self.destroy if self.deleted_by_sender && self.deleted_by_receiver
  end

  authorizing do |agent, permission|
    if permission == :read && agent == sender
      true
    elsif permission == :read && agent == receiver
      true
    end
  end
end
