require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Space do
  extend ActiveRecord::AuthorizationTestHelper

  before(:each) do
    @valid_attributes = {:name => 'title', :description => 'text',:default_logo => "models/front/space.png" }
  end

  it "should create a new instance given valid attributes" do
    Space.create(@valid_attributes).should be_valid
  end
  
  it "should not create a new instance given no name" do
    Space.create(:name => 'title').should_not be_valid
  end
  
  it "should not create a new instance given no description" do
    Space.create(:description => 'text').should_not be_valid
  end
  
  it "should not create two instances with the same name" do
    expect {
      Space.create(@valid_attributes)
      Space.create(@valid_attributes)
    }.to change{ Space.count }.by(1)
    assert_raise ActiveRecord::RecordInvalid do
      Space.create!(@valid_attributes).should be_false
    end
  end

  describe ", regarding invitations," do

    before(:each) do
  
      @space = Factory(:space)
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
        @space.update_attributes(:invitation_mails => @unregistered_user_email_1 + " , " + @unregistered_user_email_2, :invitations_role_id => @inv_role_id,
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
    before(:all) do
      @space = populated_public_space
      @admin = @space.stage_performances.detect{ |p| p.role.name == "Admin" }.agent
    end

    it_should_authorize(:admin, :update, :space)
    it_should_not_authorize(Anonymous.current, :update, :space)
  end
end
