class ShibToken < ActiveRecord::Base
  belongs_to :user
  validates :identifier, :presence => true, :uniqueness => true

  def data_as_hash
    YAML::load(self.data)
  end
end
