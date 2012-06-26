class ShibToken < ActiveRecord::Base
  belongs_to :user, :dependent => :destroy
  validates :identifier, :presence => true, :uniqueness => true
  validates :user_id, :uniqueness => true
end
