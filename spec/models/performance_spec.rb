require "spec_helper"

describe Performance do
  before do
    @space = Factory(:space)
  end

  it "should not update Performance when there is only one Admin" do
    @admin_performance = Factory(:admin_performance, :stage => @space)

    @space.users.size.should == 1

    @admin_performance.role_id = @space.class.roles.sort.first.id
    assert ! @admin_performance.valid?
  end

  it "should not delete Performance when there is only one Admin" do
    @admin_performance = Factory(:admin_performance, :stage => @space)

    @space.users.size.should == 1

    expect {
      @admin_performance.destroy.should be_false
    }.not_to change{ @space.users.count }
  end
  
  describe ", regarding Event performances," do

    before(:each) do
  
      @space = Factory(:space)
      @event = Factory(:event)
      @event.update_attribute(:space, @space)
      @role = Role.find_by_name("Invitedevent")
    
    end
    
    it "after creating a performance for a user of an event, it should create the performance Invited for the " +
      "space of that event, for the same user, if that user had no performance in that space before" do

      @registered_user = Factory(:user)
      assert_nil Performance.find_by_agent_id_and_stage_id(@registered_user.id,@event.id)
      assert_nil Performance.find_by_agent_id_and_stage_id(@registered_user.id,@space.id)

      perf = Performance.new(:agent => @registered_user, :role => @role, :stage => @event)
      perf.save

      event_performance = Performance.find_by_agent_id_and_stage_id(@registered_user.id,@event.id)
      assert_equal(@registered_user,event_performance.agent)
      assert_equal(Role.find(@role),event_performance.role)
      assert_equal(@event,event_performance.stage)
      
      space_performance = Performance.find_by_agent_id_and_stage_id(@registered_user.id,@space.id)
      assert_equal(@registered_user,space_performance.agent)
      assert_equal(Role.find_by_name("Invited"),space_performance.role)
      assert_equal(@space,space_performance.stage)
  
      event_performance.destroy
      space_performance.destroy
      @registered_user.destroy
      
    end
  
    after(:each) do
  
      @space.destroy
      @event.destroy
  
    end
  end
end

