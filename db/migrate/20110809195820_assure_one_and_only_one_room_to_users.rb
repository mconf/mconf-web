class AssureOneAndOnlyOneRoomToUsers < ActiveRecord::Migration

  def self.up
    puts "===== Deleting all the user rooms"
    BigbluebuttonRoom.where(:owner_type => 'User').each(&:destroy)

    puts "===== Creating users rooms"
    User.all.each do |u|
      name = unique_room_name(u.profile.full_name)
      param = unique_room_param(u.login)
      BigbluebuttonRoom.create!(:owner => u,
                                :server => BigbluebuttonServer.first,
                                :param => param,
                                :name => name,
                                :public => true)
    end

    puts "===== Updating space rooms"
    BigbluebuttonRoom.where(:owner_type => 'Space').each do |room|
      space = Space.find_by_id(room.owner_id)
      unless space.nil?
        # fix name and permalink
        name = unique_room_name(space.name)
        param = unique_room_param(space.permalink)

        # use the old password or generates a new one if nil
        mod_pass = room.moderator_password || ActiveSupport::SecureRandom.random_number(99999).to_s
        att_pass = room.attendee_password || ActiveSupport::SecureRandom.random_number(99999).to_s

        room.update_attributes!(:owner => space,
                                :server => BigbluebuttonServer.first,
                                :param => param,
                                :name => name,
                                :private => !space.public?,
                                :moderator_password => mod_pass,
                                :attendee_password => att_pass)
      end
    end
  end

  def self.down
  end

  private

  # Generates a unique value for BigbluebuttonRoom.name based on 'base'
  def self.unique_room_name(base)
    counter = 1
    name = base
    while BigbluebuttonRoom.where(:name => name).count > 0
      suffix = " #{counter += 1}"
      name = "#{base}#{suffix}"
    end
    name
  end

  def self.unique_room_param(base)
    counter = 1
    param = base
    while BigbluebuttonRoom.where(:param => param).count > 0
      suffix = "-#{counter += 1}"
      param = "#{base}#{suffix}"
    end
    param = param + "-" + ActiveSupport::SecureRandom.random_number(9999).to_s if param.length < 3
    param
  end

end
