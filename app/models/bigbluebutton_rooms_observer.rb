class BigbluebuttonRoomsObserver < ActiveRecord::Observer
  observe :profile

  def after_update(profile)
    if profile.user and profile.user.bigbluebutton_room
      profile.user.bigbluebutton_room.update_attribute(:name, profile.full_name)
    end
  end
end
