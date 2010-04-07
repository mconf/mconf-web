require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Admission do
  
  before(:each) do

    @space = Factory(:space)
    @event = Factory(:event)
    @admin = Factory(:admin_performance, :stage => @space).agent

    @event.update_attribute(:space, @space)
    @event.update_attribute(:author, @admin)
    @role_id_1 = Role.find_by_name("Invited").id.to_s
    @comment_1 = "This is the comment of the invitation to the event."
    @code_1 = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  
  end
  
  it "after being saved and ready to create a performance for an Event, it should" + 
    " also create a performance for the Space of that Event, with the same agent and role, " +
    "if that Space performance did not exist before" do

    @registered_user = Factory(:user_performance).agent
    params = {:role_id => @role_id_1, :email => @registered_user.email, :comment => @comment_1, :introducer => @event.author,
      :code => @code_1}
    admission_1 = @event.invitations.build params

    assert_nil Performance.find_by_agent_id_and_stage_id(@registered_user.id,@event.id)
    assert_nil Performance.find_by_agent_id_and_stage_id(@registered_user.id,@space.id)
    # Process the admission:
    admission_1.update_attributes(:accepted => true, :processed => true)
    
    event_performance = Performance.find_by_agent_id_and_stage_id(@registered_user.id,@event.id)
    assert_equal(@registered_user,event_performance.agent)
    assert_equal(Role.find(@role_id_1),event_performance.role)
    assert_equal(@event,event_performance.stage)
    
    space_performance = Performance.find_by_agent_id_and_stage_id(@registered_user.id,@space.id)
    assert_equal(@registered_user,space_performance.agent)
    assert_equal(Role.find(@role_id_1),space_performance.role)
    assert_equal(@space,space_performance.stage)

    event_performance.destroy
    space_performance.destroy
    admission_1.destroy
    @registered_user.destroy
    
  end

  it "after being saved and ready to create a performance for an Event, it should" + 
    " NOT create a performance for the Space of that Event, if that Space performance existed before" do

    @registered_user = Factory(:user_performance, :stage => @space).agent
    params = {:role_id => @role_id_1, :email => @registered_user.email, :comment => @comment_1, :introducer => @event.author,
      :code => @code_1}
    admission_1 = @event.invitations.build params

    assert !((Performance.find_by_agent_id_and_stage_id(@registered_user.id,@space.id)).nil?)
    space_performance = Performance.find_by_agent_id_and_stage_id(@registered_user.id,@space.id)
    
    assert_nil Performance.find_by_agent_id_and_stage_id(@registered_user.id,@event.id)
    # Process the admission:
    admission_1.update_attributes(:accepted => true, :processed => true)
    
    event_performance = Performance.find_by_agent_id_and_stage_id(@registered_user.id,@event.id)
    assert_equal(@registered_user,event_performance.agent)
    assert_equal(Role.find(@role_id_1),event_performance.role)
    assert_equal(@event,event_performance.stage)
    
    # We check there only exists the previous space performance by distinguishing the roles
    assert_nil Performance.find_by_agent_id_and_stage_id_and_role_id(@registered_user.id,@space.id,Role.find_by_name("Invited"))
    assert !((Performance.find_by_agent_id_and_stage_id_and_role_id(@registered_user.id,@space.id,Role.find_by_name("User").id)).nil?)

    event_performance.destroy
    space_performance.destroy
    admission_1.destroy
    @registered_user.destroy
    
  end

  after(:each) do

    @space.destroy
    @event.destroy
    @admin.destroy

  end

end