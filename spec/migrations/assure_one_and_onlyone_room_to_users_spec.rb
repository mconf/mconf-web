require 'spec_helper.rb'
require Rails.root + 'db/migrate/20110809195820_assure_one_and_only_one_room_to_users.rb'

describe AssureOneAndOnlyOneRoomToUsers, :migration => true do
  before do
    @target_migration = 20110809195820
  end

  describe ".up" do

    context "using real data", :migration_real => true do
      before { TestMigrator.load_data_and_migrate(@target_migration) }
      it 'all users and spaces need to have one and only one room' do
        User.all.each do |user|
          check_unique_room(user).should == 1
        end
        Space.all.each do |space|
          check_unique_room(space).should == 1
        end
      end
      
      it 'all rooms from users need to have the param equal the users login' do
        User.all.each do |user|
          check_param(user).should == user.login
        end
      end
    end

  end
end

def check_unique_room(model)
  if model.class == Space
    BigbluebuttonRoom.count( :conditions => ["owner_type = 'Space' and owner_id = "+model.id.to_s] )
  else
    BigbluebuttonRoom.count( :conditions => ["owner_type = 'User' and owner_id = "+model.id.to_s] )
  end
end

def check_param(user)
  room = BigbluebuttonRoom.find_by_owner_type_and_owner_id("User", user.id)
  room.param
end
