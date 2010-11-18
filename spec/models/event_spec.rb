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
        @event.update_attributes(:mails => @unregistered_user_email_1 + " , " + @unregistered_user_email_2, :invite_msg => @msg, :invit_introducer_id => @admin.id)
      end
      
      invitation_1 = Admission.find_by_email(@unregistered_user_email_1)
      assert_equal("Invitation",invitation_1.type)
      assert_equal(@unregistered_user_email_1,invitation_1.email)
      assert_equal(@event,invitation_1.group)
      assert_equal(Role.find_by_name("Invitedevent").id,invitation_1.role.id)
      assert_equal(@admin,invitation_1.introducer)
      assert_equal(@msg,invitation_1.comment)
      
      invitation_2 = Admission.find_by_email(@unregistered_user_email_2)
      assert_equal("Invitation",invitation_2.type)
      assert_equal(@unregistered_user_email_2,invitation_2.email)
      assert_equal(@event,invitation_2.group)
      assert_equal(Role.find_by_name("Invitedevent").id,invitation_2.role.id)
      assert_equal(@admin,invitation_2.introducer)
      assert_equal(@msg,invitation_2.comment)
      
      invitation_2.destroy
      invitation_1.destroy
    end
    
    it "should create Invitations to itself if it has user ids for that after saving" +
          " and those Invitations should have the proper content in their fields" do
      
      assert_difference 'Admission.count', +2 do
        @event.update_attributes(:ids => [@registered_user_1.id , @registered_user_2.id], :invite_msg => @msg, :invit_introducer_id => @admin.id)
      end
      
      invitation_1 = Admission.find_by_email(@registered_user_1.email)
      assert_equal("Invitation",invitation_1.type)
      assert_equal(@registered_user_1,invitation_1.candidate)
      assert_equal(@registered_user_1.email,invitation_1.email)
      assert_equal(@event,invitation_1.group)
      assert_equal(Role.find_by_name("Invitedevent").id,invitation_1.role.id)
      assert_equal(@admin,invitation_1.introducer)
      assert_equal(@msg,invitation_1.comment)
      
      invitation_2 = Admission.find_by_email(@registered_user_2.email)
      assert_equal("Invitation",invitation_2.type)
      assert_equal(@registered_user_2,invitation_2.candidate)
      assert_equal(@registered_user_2.email,invitation_2.email)
      assert_equal(@event,invitation_2.group)
      assert_equal(Role.find_by_name("Invitedevent").id,invitation_2.role.id)
      assert_equal(@admin,invitation_2.introducer)
      assert_equal(@msg,invitation_2.comment)
      
      invitation_2.destroy
      invitation_1.destroy
    end
    
    it "should not allow to create events with a duration less than 15 minutes" do
      event = Event.new(:name => "Win Event", :start_date => Time.now,:end_date => Time.now + 900)
      event.should be_valid     
      event = Event.new(:name => "Fail Event", :start_date => Time.now,:end_date => Time.now + 899)
      event.should_not be_valid     
      event.errors.on(:base).should == I18n.t('event.error.too_short')
    end
    
    it "should not allow to create events with a duration more than 5 days" do
      event = Event.new(:name => "Win Event", :start_date => Time.now,:end_date => Time.now + 5.days)
      event.should be_valid     
      event = Event.new(:name => "Fail Event", :start_date => Time.now,:end_date => Time.now + 6.days)
      event.should_not be_valid     
      event.errors.on(:base).should == I18n.t('event.error.max_size_excedeed', :max_days => Event::MAX_DAYS)
    end
    
    it "should move an event" do
      relative_time = 45.minutes
      start_date = @event.start_date
      end_date = @event.end_date
      @event.update_attributes(:edit_date_action => "move_event", :start_date => start_date + relative_time)
      assert_equal(@event.start_date,start_date + relative_time)
      assert_equal(@event.end_date,end_date + relative_time)      
    end
    
    it "should change the start date" do
      relative_time = 45.minutes
      start_date = @event.start_date
      end_date = @event.end_date
      @event.update_attributes(:edit_date_action => "start_date", :start_date => start_date - relative_time)
      assert_equal(@event.start_date,start_date - relative_time)
      assert_equal(@event.end_date,end_date)      
    end
    
    it "should change the end date" do
      relative_time = 45.minutes
      start_date = @event.start_date
      end_date = @event.end_date
      @event.update_attributes(:edit_date_action => "end_date", :end_date => end_date + relative_time)
      assert_equal(@event.start_date,start_date)
      assert_equal(@event.end_date,end_date + relative_time)      
    end
    describe "Agenda Entries and Event date updates" do
      
      before(:each) do
        @event = Factory(:event)
        @agenda_entry = Factory(:agenda_entry, :agenda => @event.agenda)
      end
      
      it "should move the agenda entries in an event when moving it" do
        
        relative_time = 45.minutes
        start_date = @event.start_date
        end_date = @event.end_date
        start_time = @agenda_entry.start_time
        end_time = @agenda_entry.end_time
        @event.update_attributes(:edit_date_action => "move_event", :start_date => start_date + relative_time)
        @event.should be_valid      
        assert_equal(@event.edit_date_action,"move_event")
        assert_equal(@event.start_date,start_date + relative_time)
        assert_equal(@event.end_date,end_date + relative_time)
        @agenda_entry = AgendaEntry.find(@agenda_entry.id)
        @agenda_entry.should be_valid        
        assert((@agenda_entry.start_time - (start_time + relative_time)).abs < 1.second)
        assert((@agenda_entry.end_time - (end_time + relative_time)).abs < 1.second)      
      end
      
      it "should not move the agenda entries in an event when changing its start date" do
        relative_time = 45.minutes
        start_date = @event.start_date
        end_date = @event.end_date
        start_time = @agenda_entry.start_time
        end_time = @agenda_entry.end_time
        assert_equal(@event, @agenda_entry.agenda.event)
        
        @event.update_attributes(:edit_date_action => "start_date", :start_date => start_date - relative_time)
        @event.should be_valid      
        assert_equal(@event.edit_date_action,"start_date")
        assert_equal(@event.start_date,start_date - relative_time)
        assert_equal(@event.end_date,end_date)      
        @agenda_entry.should be_valid
        assert_equal(@agenda_entry.start_time, start_time)
        assert_equal(@agenda_entry.end_time, end_time)            
      end
      
      it "should not move the agenda entries in an event when changing its end date" do
        relative_time = 45.minutes
        start_date = @event.start_date
        end_date = @event.end_date
        start_time = @agenda_entry.start_time
        end_time = @agenda_entry.end_time
        assert_equal(@event, @agenda_entry.agenda.event)
        
        @event.update_attributes(:edit_date_action => "end_date", :end_date => end_date + relative_time)
        @event.should be_valid      
        assert_equal(@event.edit_date_action,"end_date")
        assert_equal(@event.start_date,start_date)
        assert_equal(@event.end_date,end_date + relative_time)  
        @agenda_entry.should be_valid    
        assert_equal(@agenda_entry.start_time, start_time)
        assert_equal(@agenda_entry.end_time, end_time)      
        
      end
      
    end
    
    
  end
end
