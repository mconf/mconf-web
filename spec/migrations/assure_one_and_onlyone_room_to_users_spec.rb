# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper.rb'
require Rails.root + 'db/migrate/20110809195820_assure_one_and_only_one_room_to_users.rb'

describe AssureOneAndOnlyOneRoomToUsers, :migration => true do

  describe ".up" do

    context "using real data", :migration_real => true do

      it 'all users and spaces need to have one and only one room' do
        User.all.each do |user|
          get_room_count_for(user).should == 1
        end
        Space.all.each do |space|
          get_room_count_for(space).should == 1
        end
      end

      it 'all user rooms need to have the param equal the users login' do
        User.all.each do |user|
          user.bigbluebutton_room.param.should =~ /^((#{user.login})|(#{user.login}-.*))$/
        end
      end

      it 'all space rooms need to have the param matching the space\'s permalink' do
        Space.all.each do |space|
          space.bigbluebutton_room.param.should =~ /^((#{space.permalink})|(#{space.permalink}-.*))$/
        end
      end

      it 'space rooms are private if the space is private' do
        Space.all.each do |space|
          space.bigbluebutton_room.private.should == !space.public?
        end
      end

      it 'private rooms have passwords defined' do
        BigbluebuttonRoom.all.each do |room|
          if room.private
            room.moderator_key.should_not be_nil
            room.attendee_key.should_not be_nil
          end
        end
      end

    end

  end
end

def get_room_count_for(model)
  if model.class == Space
    BigbluebuttonRoom.count(:conditions => ["owner_type = 'Space' and owner_id = " + model.id.to_s])
  else
    BigbluebuttonRoom.count(:conditions => ["owner_type = 'User' and owner_id = " + model.id.to_s])
  end
end
