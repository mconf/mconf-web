class PrivateMessage < ActiveRecord::Base
  belongs_to :sender,  :class_name => "User"
  belongs_to :receiver, :class_name => "User"

  acts_as_resource :per_page => 10

  validates_presence_of :sender_id, :receiver_id , :title, :body,
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

  def local_affordances
    [ ActiveRecord::Authorization::Affordance.new(sender,   :read),
      ActiveRecord::Authorization::Affordance.new(receiver, :read) ]
  end
end
