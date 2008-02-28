class Machine < ActiveRecord::Base
  has_many :events, :through => :participants
  has_many :participants
  has_and_belongs_to_many :users
  
end
