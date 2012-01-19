require "spec_helper"

describe User do
  it "should automatically create the profile of a user after creating the user" do
    @user = Factory.create(:user)
    @user.profile.should_not be_nil
  end

  it "should automatically create the bbb room of a user after creating the user" do
    @user = Factory.create(:user)
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

  [ :receive_digest ].each do |attribute|
    it { should allow_mass_assignment_of(attribute) }
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

  describe "#accessible_rooms" do
    let(:user) { Factory.create(:user) }
    let(:user_room) { Factory.create(:bigbluebutton_room, :owner => user) }
    let(:private_space_member) { Factory.create(:private_space) }
    let(:private_space_not_member) { Factory.create(:private_space) }
    let(:public_space_member) { Factory.create(:public_space) }
    let(:public_space_not_member) { Factory.create(:public_space) }
    before do
      user_room
      public_space_not_member
      Factory.create(:user_performance, :agent => user, :stage => private_space_member)
      Factory.create(:user_performance, :agent => user, :stage => public_space_member)
    end

    subject { user.accessible_rooms }
    # it { subject.count.should == 4 }
    it { subject.should == subject.uniq }
    it { should include(user_room) }
    it { should include(private_space_member.bigbluebutton_room) }
    it { should include(public_space_member.bigbluebutton_room) }
    it { should include(public_space_not_member.bigbluebutton_room) }
    it { should_not include(private_space_not_member.bigbluebutton_room) }
  end

end
