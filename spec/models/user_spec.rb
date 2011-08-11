require "spec_helper"

describe User do
  it "should automatically create the profile of a user after creating the user" do
    @user = Factory(:user)
    @user.profile.should_not be_nil
  end
  
  it "should automatically create the bbb room of a user after creating the user" do
    @user = Factory(:user)
    @user.bigbluebutton_room.should_not be_nil
  end

  describe "with valid attributes" do
    it "should create a new instance" do
      Factory.build(:user).should be_valid
    end

    it "should not create a new instance given no email" do
      User.create(:email => nil).should_not be_valid
    end
  end

  describe "login uses a unique permalink" do
    let(:user) { Factory.create(:user, :_full_name => "User Name", :login => nil) }
    let(:user2) { Factory.create(:user, :_full_name => user.full_name, :login => nil) }

    it { user.login.should eq("user-name") }
    it { user2.login.should eq("user-name-2") }

    describe "and cannot conflict with some space's permalink" do
      let(:space) { Factory.create(:space, :name => "User Name") }

      describe "when a user is created" do
        it { space.permalink.should eq("user-name") }
        it {
          space
          user
          user2
          user.login.should eq("user-name-2")
          user2.login.should eq("user-name-3")
        }
      end

      describe "when a user is updated" do
        let(:user3) { Factory.create(:user, :_full_name => "User Name New", :login => nil) }
        it { space.permalink.should eq("user-name") }
        it { user3.login.should eq("user-name-new") }
        it {
          space
          user3.update_attributes(:login => "user-name")
          user3.errors[:login].should include(I18n.t('activerecord.errors.messages.taken'))
        }
        it { 
          user3.update_attributes(:login => "user-name-bbb")
          user3.bigbluebutton_room.param.should eq("user-name-bbb")
        }
      end

      describe "#bigbluebutton room" do
        it { should have_one(:bigbluebutton_room).dependent(:destroy) }
        it { should accept_nested_attributes_for(:bigbluebutton_room) }
      end
    end

  end

end
