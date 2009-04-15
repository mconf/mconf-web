class PrivateMessage < ActiveRecord::Base
  belongs_to :sender,  :class_name => "User"
  belongs_to :receiver, :class_name => "User"

  acts_as_resource :per_page => 10

  validates_presence_of :sender_id, :receiver_id , :title, :body,
                          :message => "must be specified"
                          
  def validate
    unless User.find(self.sender_id).fellows.include?(User.find(self.receiver_id))
      errors.add(:receiver_id, "Receiver and sender have to share one or more spaces.")
    end
  end
end
