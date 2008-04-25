class Profile < ActiveRecord::Base
  belongs_to :user
  
 validates_presence_of     :name, :lastname, :phone, :city, :country
  def see_profile_by?(user)
    
  end
end
