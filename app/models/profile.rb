class Profile < ActiveRecord::Base
  acts_as_taggable
  has_one :logotype , :as => 'logotypable'
  belongs_to :user
  
 validates_presence_of     :name, :lastname, :phone, :city, :country,:organization
  def see_profile_by?(user)
    
  end
  
 
end
