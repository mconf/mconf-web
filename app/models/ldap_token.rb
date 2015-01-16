class LdapToken < ActiveRecord::Base
  # attr_accessible :data, :identifier, :user_id
  belongs_to :user
  validates :identifier, :presence => true, :uniqueness => true
end
