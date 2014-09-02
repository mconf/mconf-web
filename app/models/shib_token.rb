class ShibToken < ActiveRecord::Base
  belongs_to :user
  validates :identifier, :presence => true, :uniqueness => true

  serialize :data, Hash

  def user_with_disabled
    User.with_disabled.where(id: self.user_id).first
  end
end
