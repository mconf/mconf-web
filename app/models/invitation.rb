class Invitation < ActiveRecord::Base
  DELIMITER = (/,|;| /)

  belongs_to :user
  belongs_to :space
  belongs_to :role

  validates_presence_of :user_id, :space_id, :role_id, :email

  def invited_user
    User.find_by_email(email)
  end

  def to_performance
    Performance.create!(:agent => invited_user, :stage => space, :role => role)
    destroy
  end
end

