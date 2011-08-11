require "spec_helper"

describe Space do
  extend ActiveRecord::AuthorizationTestHelper

  it "creates a new instance given valid attributes" do
    Factory.build(:space).should be_valid
  end

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:description) }
  it { should validate_uniqueness_of(:name) }

  describe ", regarding invitations," do

    before(:each) do
      @space = Factory(:private_space)
      @admin = Factory(:admin_performance, :stage => @space).agent
      @unregistered_user_email_1 = "unregistered_1@example.com"
      @unregistered_user_email_2 = "unregistered_2@example.com"
      @registered_user_1 = Factory(:user_performance).agent
      @registered_user_2 = Factory(:user_performance).agent
      @msg = "This is the message of the invitation."
      @inv_role_id = Space.role("User").id
    end

    it "should create Invitations to itself if it has mail addresses for that after saving" +
      " and those Invitations should have the proper content in their fields" do

      expect {
        @space.update_attributes(:invitation_mails => @unregistered_user_email_1 + " , " + @unregistered_user_email_2,
                                 :invitations_role_id => @inv_role_id,
                                 :invite_msg => @msg, :inviter_id => @admin.id)
      }.to change{ Admission.count }.by(2)

      invitation_1 = Admission.find_by_email(@unregistered_user_email_1)
      assert_equal("Invitation",invitation_1.type)
      assert_equal(@unregistered_user_email_1,invitation_1.email)
      assert_equal(@space,invitation_1.group)
      assert_equal(@inv_role_id,invitation_1.role.id)
      assert_equal(@admin,invitation_1.introducer)
      assert_equal(@msg,invitation_1.comment)

      invitation_2 = Admission.find_by_email(@unregistered_user_email_2)
      assert_equal("Invitation",invitation_2.type)
      assert_equal(@unregistered_user_email_2,invitation_2.email)
      assert_equal(@space,invitation_2.group)
      assert_equal(@inv_role_id,invitation_2.role.id)
      assert_equal(@admin,invitation_2.introducer)
      assert_equal(@msg,invitation_2.comment)

      invitation_2.destroy
      invitation_1.destroy
    end


    it "should create Invitations to itself if it has user ids for that after saving" +
      " and those Invitations should have the proper content in their fields" do

      expect {
        @space.update_attributes(:invitation_ids => [@registered_user_1.id , @registered_user_2.id], :invitations_role_id => @inv_role_id,
          :invite_msg => @msg, :inviter_id => @admin.id)
      }.to change{ Admission.count }.by(2)

      invitation_1 = Admission.find_by_email(@registered_user_1.email)
      assert_equal("Invitation",invitation_1.type)
      assert_equal(@registered_user_1,invitation_1.candidate)
      assert_equal(@registered_user_1.email,invitation_1.email)
      assert_equal(@space,invitation_1.group)
      assert_equal(@inv_role_id,invitation_1.role.id)
      assert_equal(@admin,invitation_1.introducer)
      assert_equal(@msg,invitation_1.comment)

      invitation_2 = Admission.find_by_email(@registered_user_2.email)
      assert_equal("Invitation",invitation_2.type)
      assert_equal(@registered_user_2,invitation_2.candidate)
      assert_equal(@registered_user_2.email,invitation_2.email)
      assert_equal(@space,invitation_2.group)
      assert_equal(@inv_role_id,invitation_2.role.id)
      assert_equal(@admin,invitation_2.introducer)
      assert_equal(@msg,invitation_2.comment)

      invitation_2.destroy
      invitation_1.destroy
    end

    after(:each) do
      #remove all the stuff created
      @space.destroy
      @admin.destroy
      @registered_user_1.destroy
      @registered_user_2.destroy
    end

  end

  # Authorization
  describe "being public" do
    before(:each) do
      @space = populated_public_space
      @admin = @space.stage_performances.detect{ |p| p.role.name == "Admin" }.agent
    end

    it_should_authorize(:admin, :update, :space)
    it_should_not_authorize(Anonymous.current, :update, :space)
  end

  describe "#bigbluebutton room" do
    it { should have_one(:bigbluebutton_room).dependent(:destroy) }
    it { should accept_nested_attributes_for(:bigbluebutton_room) }
  end

  describe "when a space is updated" do
    let(:space) { Factory.create(:space, :name => "Space Name") }
    before { space.update_attributes(:name => "New Name") }
    it { space.permalink.should eq("new-name") }
    it { space.bigbluebutton_room.param.should == space.permalink }
    it { space.bigbluebutton_room.name.should == space.name }
  end

  describe "#permalink is unique" do
    let(:space) { Factory.create(:space, :name => "Space Name") }
    it { space.permalink.should eq("space-name") }

    describe "and cannot conflict with some users's login" do
      let(:user) { Factory.create(:user, :login => "space-name") }

      describe "when a space is created" do
        it { user.login.should eq("space-name") }
        it {
          user
          space
          space.permalink.should eq("space-name-2")
        }
      end

      describe "when a space is updated" do
        let(:user2) { Factory.create(:user, :login => "space-name-for-user") }
        it { user2.permalink.should eq("space-name-for-user") }
        it {
          user2
          space
          space.update_attributes(:name => user2.login)
          space.errors[:permalink].should include(I18n.t('activerecord.errors.messages.taken'))
        }
        it {
          space.update_attributes(:name => "New Name")
          space.permalink.should eq("new-name")
          space.bigbluebutton_room.param.should == space.permalink
        }
      end
    end

  end

end
