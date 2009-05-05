class Membership < ActiveRecord::Base
  belongs_to :group, :dependent => :destroy
  belongs_to :user, :dependent => :destroy

  validates_presence_of :group_id, :user_id
end
