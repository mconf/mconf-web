class Membership < ActiveRecord::Base
  belongs_to :group, :dependent => :destroy
  belongs_to :user, :dependent => :destroy
end
