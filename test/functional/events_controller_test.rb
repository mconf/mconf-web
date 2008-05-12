require File.dirname(__FILE__) + '/../test_helper'

class EventsControllerTest < ActionController::TestCase
  include CMS::AuthenticationTestHelper

  fixtures   :event_datetimes, :events_users, :events, :machines_users, :machines, :participants, :profiles, :users

  def setup
    @controller = EventsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
    
  
  #delete supereventomolon, that is the event manually created
  def teardown
    if evento = Event.find_by_name("supereventomolon")
      evento.destroy
    end
  end
  
  #A non authenticated user should be redirected to create a new session and the message is "Please log in"
  def test_get_index_should_be_redirected
    get :index
    assert_redirected_to :controller => "sessions", :action => "new"
  end


  #test if the login works correctly
  def test_login
    login_as("user_admin")   #administrator of the app
    login_as("user_normal") # a normal user
    login_as("user_disabled")  # a disabled user
    login_as("user_no_resources") # a user with no resources assigned
  end
  

  def test_index
    login_as("user_normal")
    get :index
    assert_response :success
    assert_template "index"
  end
  
  
  def test_index_with_date
    login_as("user_normal")
    get :index, :date_start_day => "2015-01-01"
    assert_response :success
    assert_template "index"
  end
  
  
  def test_index_with_date_2
    login_as("user_normal")
    get :index, :date_start_day => "2015-04-28"
    assert_response :success
    assert_template "index"
  end
  
  
  def test_index_with_date_3
    login_as("user_normal")
    get :index, :date_start_day => "1915-04-28"
    assert_response :success
    assert_template "index"
  end
  
  
  def test_index_with_date_4
    login_as("user_normal")
    get :index, :date_start_day => "3015-12-12"
    assert_response :success
    assert_template "index"
  end
  
  
  def test_list_timetable
    login_as("user_normal")
    get :show_timetable
    assert_response :success
    assert_template "_time_table"
  end


  def test_list_timetable_with_date_and_machine
    login_as("user_normal")
    get :show_timetable, :date_start_day => "2015-01-01", :machine => "1"
    assert_response :success
    assert_template "_time_table"
  end
    
  
  def test_list_timetable_with_date_and_machine_2
    login_as("user_normal")
    get :show_timetable, :date_start_day => "2015-02-02", :machine => "1"
    assert_response :success
    assert_template "_time_table"
  end
  
  
  def test_list_timetable_with_date_and_machine_3
    login_as("user_normal")
    get :show_timetable, :date_start_day => "2005-04-27", :machine => "2"
    assert_response :success
    assert_template "_time_table"
  end
  
  
  def test_list_timetable_with_date_and_machine_4
    login_as("user_normal")
    get :show_timetable, :date_start_day => "2016-04-27", :machine => "0"
    assert_response :success
    assert_template "_time_table"
  end
  
  
  def test_list_timetable_with_date_and_machine_5
    login_as("user_normal")
    get :show_timetable, :date_start_day => "2007-04-28", :machine => "0"
    assert_response :success
    assert_template "_time_table"
  end
  
  
  def test_list_timetable_with_date_and_machine_6
    login_as("user_normal")
    get :show_timetable, :date_start_day => "2005-04-28", :machine => "0"
    assert_response :success
    assert_template "_time_table"
  end
  
  
  def test_list_timetable_with_date_and_machine_7
    login_as("user_normal")
    get :show_timetable, :date_start_day => "1915-04-28", :machine => "0"
    assert_response :success
    assert_template "_time_table"
  end
  
  
  def test_list_timetable_with_date_and_machine_8
    login_as("user_normal")
    get :show_timetable, :date_start_day => "3005-12-12", :machine => "0"
    assert_response :success
    assert_template "_time_table"
  end
  

  def test_new_with_no_resources
    login_as("user_no_resources") 
    get :new
    assert_redirected_to :action => "show"  
  end
    
  
  def test_new_good
    login_as("user_normal")
    get :new
    assert_response :success
    assert_template "new"
  end
  
  
  def test_new_good_with_date
    login_as("user_normal")
    get :new, :date_start_day => "2006-11-19"
    assert_response :success
    assert_template "new"
  end
  
  
  def test_new_good_with_date_2
    login_as("user_normal")
    get :new, :date_start_day => "1915-11-19"
    assert_response :success
    assert_template "new"
  end
  
  
  def test_new_good_with_date_3
    login_as("user_normal")
    get :new, :date_start_day => "2037-12-12"
    assert_response :success
    assert_template "new"
  end
  
  
  def test_new_good_with_date_4
    login_as("user_normal")
    get :new, :date_start_day => "2006-11-19", :machine =>"1"
    assert_response :success
    assert_template "new"
  end

  
  def test_create_with_no_resources
    login_as("user_no_resources") 
    post :create
    assert flash[:notice].include?('no resources')
    assert_redirected_to :action => "show" 
  end
  
  
  def test_create_good_warning_min_length
    login_as("user_normal")
    post :create, :is_valid_time0=>"true",:tag=>{"add_tag"=>"bueno"}, :accomplished0=>"false", :event=>{"name"=>"supereventomolon", "service"=>"meeting.act", "description"=>"aass", "password"=>"aa", "quality"=>"512K", "all_participants_sites"=>"5"}, :los_indices=>"1", :is_valid_participant0=>"true", :start_date0=>"June 27, 2008 01:52",  :end_date0 =>"June 27, 2008 01:55"
    assert flash[:notice].include?('smaller')
    assert_redirected_to container_events_url(:container_id => users("user_normal").id, :container_type => "users", :date_start_day => assigns(:event).event_datetimes[0].start_date )
  end
  
      
  def test_create_good_warning_max_length
    login_as("user_normal")
    post :create, :is_valid_time0=>"true",:tag=>{"add_tag"=>"bueno"}, :accomplished0=>"false", :event=>{"name"=>"supereventomolon", "service"=>"meeting.act", "description"=>"aass", "password"=>"aa", "quality"=>"512K", "all_participants_sites"=>5}, :los_indices=>"1", :is_valid_participant0=>"true", :start_date0=>"May 19, 2008 02:00",  :end_date0 =>"June 27, 2008 02:00"
    assert_redirected_to container_events_url(:container_id => users("user_normal").id, :container_type => "users", :date_start_day => assigns(:event).event_datetimes[0].start_date )
  end
  
  
   
  def test_create_good
    login_as("user_normal")
    post :create, :is_valid_time0=>"true", :tag=>{"add_tag"=>"bueno"}, :accomplished0=>"false", :event=>{"name"=>"supereventomolon", "service"=>"meeting.act", "description"=>"aass", "password"=>"aa", "quality"=>"512K", "all_participants_sites"=>5}, :los_indices=>"1", :is_valid_participant0=>"true", :start_date0=>"May 19, 2008 02:00",  :end_date0 =>"May 19, 2008 06:00"
    assert_equal 'Event was successfully created.', flash[:notice]
    assert_redirected_to container_events_url(:container_id => users("user_normal").id, :container_type => "users", :date_start_day => assigns(:event).event_datetimes[0].start_date )
  end
  
  
  def test_create_good_2
    #con otros valores
    login_as("user_normal")
    post :create, :is_valid_time0=>"true",:tag=>{"add_tag"=>"bueno"}, :accomplished0=>"false", :event=>{"name"=>"supereventomolon", "service"=>"meeting.act", "description"=>"aass", "password"=>"aa", "quality"=>"512K", "all_participants_sites"=>5}, :los_indices=>"1", :is_valid_participant0=>"true", :start_date0=>"June 27, 2008 01:12",  :end_date0 =>"June 27, 2008 02:27"
    assert_equal 'Event was successfully created.', flash[:notice]
    assert_redirected_to container_events_url(:container_id => users("user_normal").id, :container_type => "users", :date_start_day => assigns(:event).event_datetimes[0].start_date )
  end
  
  
  def test_create_good_3
    #con otros valores
    login_as("user_normal")
    post :create, :is_valid_time0=>"true",:tag=>{"add_tag"=>"bueno"},:accomplished0=>"false", :event=>{"name"=>"supereventomolon", "service"=>"meeting.act", "description"=>"aass", "password"=>"aa", "quality"=>"512K", "all_participants_sites"=>5}, :los_indices=>"1", :is_valid_participant0=>"true",:is_valid_participant1=>"true", :start_date0=>"December 19, 2008 02:03",  :end_date0 =>"December 19, 2008 12:00"
    assert_equal 'Event was successfully created.', flash[:notice]
    assert_redirected_to container_events_url(:container_id => users("user_normal").id, :container_type => "users", :date_start_day => assigns(:event).event_datetimes[0].start_date )
  end
  
  
  def test_create_good_integer_values
    #con valores numericos en vez de strings
    login_as("user_normal")
    post :create, :is_valid_time0=>"true",:tag=>{"add_tag"=>"bueno"}, :accomplished0=>"false", :event=>{"name"=>"supereventomolon", "service"=>"meeting.act", "description"=>"aass", "password"=>"aa", "quality"=>"512K", "all_participants_sites"=>5}, :los_indices=>"1", :is_valid_participant0=>"true", :start_date0=>"January 19, 2008 02:00",  :end_date0 =>"January 19, 2008 04:40"
    assert_equal 'Event was successfully created.', flash[:notice]
    assert_redirected_to container_events_url(:container_id => users("user_normal").id, :container_type => "users", :date_start_day => assigns(:event).event_datetimes[0].start_date )
  end
  
  
  def test_create_good_2_datetimes
    login_as("user_normal")
    post :create, :is_valid_time0=>"true",:tag=>{"add_tag"=>"bueno"},:is_valid_time1=>"true", :accomplished0=>"false", :event=>{"name"=>"supereventomolon", "service"=>"meeting.act", "description"=>"aass", "password"=>"aa", "quality"=>"512K", "all_participants_sites"=>5}, :los_indices=>"1", :is_valid_participant0=>"true", :start_date0=>"May 19, 2008 02:00",  :end_date0 =>"May 19, 2008 05:55", :start_date1=>"June 19, 2008 02:00",  :end_date1 =>"June 19, 2008 03:03"
    assert_equal 'Event was successfully created.', flash[:notice]
    assert_redirected_to container_events_url(:container_id => users("user_normal").id, :container_type => "users", :date_start_day => assigns(:event).event_datetimes[0].start_date )
  end
  
  
  def test_create_good_3_years_long
    #evento que dura 3 años
    login_as("user_normal")
    post :create, :is_valid_time0=>"true",:tag=>{"add_tag"=>"bueno"}, :accomplished0=>"false", :event=>{"name"=>"supereventomolon", "service"=>"meeting.act", "description"=>"aass", "password"=>"aa", "quality"=>"512K", "all_participants_sites"=>5}, :los_indices=>"1", :is_valid_participant0=>"true",:is_valid_participant1=>"true", :start_date0=>"May 19, 2008 02:00",  :end_date0 =>"May 27, 2011 02:00"
    assert flash[:notice].include?('bigger')
    assert_redirected_to container_events_url(:container_id => users("user_normal").id, :container_type => "users", :date_start_day => assigns(:event).event_datetimes[0].start_date )
  end
     
  
  def test_create_with_error_in_datetimes
    login_as("user_normal")
    post :create, :is_valid_time0=>"true",:tag=>{"add_tag"=>"bueno"}, :accomplished0=>"false", :event=>{"name"=>"supereventomolon", "service"=>"meeting.act", "description"=>"aass", "password"=>"aa", "quality"=>"512K", "all_participants_sites"=>5}, :los_indices=>"1", :is_valid_participant0=>"true", :start_date0=>"May 19, 2008 02:00",  :end_date0 =>"May 17, 2008 02:00"
    #now i am not redirected
    assert_response :success
    assert @response.body.include?("errors")
    assert @response.body.include?("Participants")
  end    
      
  def test_create_with_error_in_datetimes_2
    login_as("user_normal")
    post :create, :is_valid_time0=>"true",:tag=>{"add_tag"=>"bueno"}, :accomplished0=>"false", :event=>{"name"=>"supereventomolon", "service"=>"meeting.act", "description"=>"aass", "password"=>"aa", "quality"=>"512K", "all_participants_sites"=>5}, :los_indices=>"1", :is_valid_participant0=>"true", :start_date0=>"May 19, 2008 02:00",  :end_date0 =>"May 27, 2008 02:00", :start_date1=>"May 19, 2008 02:00",  :end_date1 =>"May 27, 2007 02:00"
    #now i am not redirected
    assert_response :success
  end
  
  
  def test_create_with_error_in_datetimes_3
    login_as("user_normal")
    post :create, :is_valid_time0=>"true",:tag=>{"add_tag"=>"bueno"}, :is_valid_time1=>"true", :accomplished0=>"false", :event=>{"name"=>"supereventomolon", "service"=>"meeting.act", "description"=>"aass", "password"=>"aa", "quality"=>"512K", "all_participants_sites"=>5}, :los_indices=>"1", :is_valid_participant0=>"true", :start_date0=>"May 19, 2008 02:00",  :end_date0 =>"May 27, 2008 02:00", :start_date1=>"May 19, 2008 02:00",  :end_date1 =>"June 27, 2008 02:00"
    #now i am not redirected
    assert_response :success
  end 
  
  
  def test_edit_with_no_resources
     login_as("user_no_resources") 
    post :edit, :id=>38
    assert flash[:notice].include?('no resources')
    assert_redirected_to :action => "show"  
  end
  
  
  def test_edit_an_event_that_is_not_mine
    login_as("user_normal")
    post :edit, :id=>40
    assert_equal 'Action not allowed.', flash[:notice]    
    assert_redirected_to :action => "show"  
  end
  
  
  def test_edit_good
    login_as("user_admin")
    post :edit, :id=>38
    assert_template "edit"  
  end
  
  
  def test_edit_good_2
    login_as("user_normal")
    post :edit, :id=>38
    assert_template "edit"    
  end


  def test_update_an_event_that_is_not_mine
    login_as("user_normal")
    post :update, :id=>1
    assert_equal "Action not allowed.", flash[:notice]    
    assert_redirected_to :action => "show"  
  end
  
  
  def test_update_good
    login_as("user_admin")
    post :update, :id=>38, :is_valid_time0=>"true",:tag=>{"add_tag"=>"bueno"}, :accomplished0=>"false", :old_name=>"public/xedls/moro-16-11-2006-at-0-0.xedl", :event=>{"name"=>"supereventomolon", "service"=>"meeting.act", "description"=>"aass", "password"=>"aa", "quality"=>"512K", "all_participants_sites"=>5}, :los_indices=>"1", :is_valid_participant0=>"true", :start_date0=>"May 19, 2008 02:00",  :end_date0 =>"May 27, 2008 02:00"
    assert flash[:notice].include?('successfully')
    assert_redirected_to :action => "show" 
  end


  def test_update_good_2
    login_as("user_admin")
    post :update, :id=>38, :is_valid_time0=>"true",:tag=>{"add_tag"=>"bueno"}, :accomplished0=>"false", :old_name=>"public/xedls/moro-16-11-2006-at-0-0.xedl", :event=>{"name"=>"supereventomolon", "service"=>"meeting.act", "description"=>"aass", "password"=>"aa", "quality"=>"512K", "all_participants_sites"=>5}, :los_indices=>"1", :is_valid_participant0=>"true", :start_date0=>"January 19, 2008 02:00",  :end_date0 =>"January 27, 2008 02:00", :start_date1=>"June 19, 2008 02:00",  :end_date1 =>"June 27, 2008 02:00"
    assert flash[:notice].include?('successfully')
    assert_redirected_to :action => "show" 
  end


  def test_destroy_an_event_that_is_not_mine
    login_as("user_normal")
    post :destroy, :id=>1
    assert_equal "Action not allowed.", flash[:notice]    
    assert_redirected_to :action => "show"  
  end
  
  
  def test_destroy_good
    login_as("user_admin")
    post :destroy, :id=>38
    assert flash[:notice].include?('successfully')
    assert_redirected_to :action => "show"    
    assert_raise(ActiveRecord::RecordNotFound) {post :edit, :id=>38}
  end
  
  
  def test_show_summary_good
    post :show_summary, :event_id=>38
    assert_template "show_summary"
  end
  
  
  def test_copy_next_week
    login_as("user_admin")
    post :copy_next_week, :indice => 1, :date_start_day => "2006-12-11", :date_end_day => "2006-12-12"
    assert_response :success
    assert_template "_form_datetimes_edit"
  end
  
  
  def test_copy_next_week_2
    login_as("user_admin")
    post :copy_next_week, :indice => 2, :date_start_day => "2036-12-11", :date_end_day => "2037-12-12"
    assert_response :success
    assert_template "_form_datetimes_edit"
  end
  
  
  def test_add_time
    login_as("user_admin")
    post :add_time, :indice => 1, :date_start_day => "2006-12-12"
    assert_response :success
    assert_template "_form_datetimes_edit"
  end
  
  
  def test_add_time_2
    login_as("user_admin")
    post :add_time, :indice => 1, :date_start_day => "2036-12-12"
    assert_response :success
    assert_template "_form_datetimes_edit"
  end
  
  
  def test_remove_time
    login_as("user_admin")
    post :remove_time, :indice => 1
    assert_response :success
    assert_template "_hidden_field"
  end
  
  
  def test_remove_time_2
    login_as("user_admin")
    post :remove_time, :indice => 2
    assert_response :success
    assert_template "_hidden_field"
  end


  def test_add_participant
    login_as("user_admin")
    post :add_participant, :indice => 1
    assert_response :success
    assert_template "_form_participants"
  end
  
  
  def test_remove_participant
    login_as("user_admin")
    post :remove_participant, :indice => 1
    assert_response :success
    assert_template "_hidden_field"
  end
  
  
  def test_export_ical
    login_as("user_normal")
    post :export_ical, :id => 38
    assert @response.body.include?("VCALENDAR")
  end

end
