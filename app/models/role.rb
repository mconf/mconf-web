class Role < ActiveRecord::Base
  # TODO: permissions
  # has_many :invitations

  has_many :permissions
  validates :name, :presence => true, :uniqueness => true
end
