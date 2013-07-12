class BigbluebuttonRoomsObserver < ActiveRecord::Observer
  observe :bigbluebutton_room

  def after_create(room)
    create_metadata(room)
  end

  def after_update(room)
    create_metadata(room)
  end

  protected

  def create_metadata(room)
    title = room.metadata.where(:name => configatron.metadata.title).first
    room.metadata.create(:name => configatron.metadata.title) if title.nil?

    description = room.metadata.where(:name => configatron.metadata.description).first
    room.metadata.create(:name => configatron.metadata.description) if description.nil?
  end
end
