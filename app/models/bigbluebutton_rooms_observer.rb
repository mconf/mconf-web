class BigbluebuttonRoomsObserver < ActiveRecord::Observer
  observe :profile
  
  def after_update(profile)
    profile.user.bigbluebutton_room.update_attribute(:name, profile.full_name)
  end
end
