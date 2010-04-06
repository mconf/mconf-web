require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Event do
  it "should work with Station container_and_ancestors method" do
    @event = Factory(:event_public)
    assert_equal @event.container_and_ancestors, [ @event, @event.space ]
  end
  
  describe ", regarding invitations," do

    before(:each) do
  
      @space = Factory(:space)
      @event = Factory(:event)
      @admin = Factory(:admin_performance, :stage => @space).agent
      @unregistered_user_email_1 = "unregistered_1@example.com"
      @unregistered_user_email_2 = "unregistered_2@example.com"
      @registered_user_1 = Factory(:user_performance).agent
      @registered_user_2 = Factory(:user_performance).agent
      @msg = "This is the message of the invitation."
      
      @event.update_attribute(:space, @space)
      @event.update_attribute(:author, @admin)
      
    end

    it "should create Invitations to itself if it has mail addresses for that after saving" +
      " and those Invitations should have the proper content in their fields" do

      assert_difference 'Admission.count', +2 do
        @event.update_attributes(:mails => @unregistered_user_email_1 + " , " + @unregistered_user_email_2, :invite_msg => @msg)
      end

      invitation_1 = Admission.find_by_email(@unregistered_user_email_1)
      assert_equal("Invitation",invitation_1.type)
      assert_equal(@unregistered_user_email_1,invitation_1.email)
      assert_equal(@event,invitation_1.group)
      assert_equal(Role.find_by_name("Invited").id,invitation_1.role.id)
      assert_equal(@admin,invitation_1.introducer)
      assert_equal(@msg,invitation_1.comment)
      
      invitation_2 = Admission.find_by_email(@unregistered_user_email_2)
      assert_equal("Invitation",invitation_2.type)
      assert_equal(@unregistered_user_email_2,invitation_2.email)
      assert_equal(@event,invitation_2.group)
      assert_equal(Role.find_by_name("Invited").id,invitation_2.role.id)
      assert_equal(@admin,invitation_2.introducer)
      assert_equal(@msg,invitation_2.comment)

      invitation_2.destroy
      invitation_1.destroy
    end

    it "should create Invitations to itself if it has user ids for that after saving" +
      " and those Invitations should have the proper content in their fields" do

      assert_difference 'Admission.count', +2 do
        @event.update_attributes(:ids => [@registered_user_1.id , @registered_user_2.id], :invite_msg => @msg)
      end

      invitation_1 = Admission.find_by_email(@registered_user_1.email)
      assert_equal("Invitation",invitation_1.type)
      assert_equal(@registered_user_1,invitation_1.candidate)
      assert_equal(@registered_user_1.email,invitation_1.email)
      assert_equal(@event,invitation_1.group)
      assert_equal(Role.find_by_name("Invited").id,invitation_1.role.id)
      assert_equal(@admin,invitation_1.introducer)
      assert_equal(@msg,invitation_1.comment)
      
      invitation_2 = Admission.find_by_email(@registered_user_2.email)
      assert_equal("Invitation",invitation_2.type)
      assert_equal(@registered_user_2,invitation_2.candidate)
      assert_equal(@registered_user_2.email,invitation_2.email)
      assert_equal(@event,invitation_2.group)
      assert_equal(Role.find_by_name("Invited").id,invitation_2.role.id)
      assert_equal(@admin,invitation_2.introducer)
      assert_equal(@msg,invitation_2.comment)

      invitation_2.destroy
      invitation_1.destroy
    end

    after(:each) do 
      #remove all the stuff created
      @space.destroy
      @admin.destroy
      @event.destroy
      @registered_user_1.destroy
      @registered_user_2.destroy
    end

  end
end


