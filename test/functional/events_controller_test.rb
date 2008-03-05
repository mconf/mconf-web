require File.dirname(__FILE__) + '/../test_helper'

include AuthenticatedTestHelper

class EventsControllerTest < ActionController::TestCase
  fixtures   :event_datetimes, :events_users, :events, :machines_users, :machines, :participants, :profiles, :users

  def setup
    @controller = EventsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  #A non authenticated user should be redirected to create a new session and the message is "Please log in"
  def test_get_index_should_be_redirected
    get :index
    assert_redirected_to :controller => "sessions", :action => "new"
    assert_equal "Please log in", flash[:notice]
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
    post :create, :is_valid_time0=>"true", :participant0=>{"radiate_multicast"=>"0", "fec"=>"0", "role"=>"interactive", "machine_id"=>"1", "description"=>"", "machine_id_connected_to"=>"0"}, :accomplished0=>"false", :event=>{"name"=>"aaaaaaaa", "service"=>"meeting.act", "description"=>"aass", "password"=>"aa", "quality"=>"512K"}, :los_indices=>"1", :is_valid_participant0=>"true", :datetime0=>{"end_date(3i)"=>"14", "end_date(4i)"=>"13", "end_date(5i)"=>"51", "start_date(1i)"=>"2017", "start_date(2i)"=>"11", "start_date(3i)"=>"14", "start_date(4i)"=>"13", "start_date(5i)"=>"50", "end_date(1i)"=>"2017", "end_date(2i)"=>"11"}
    assert flash[:notice].include?('smaller')
    assert_redirected_to :action => "show"
  end
  
      
  def test_create_good_warning_max_length
    login_as("user_normal")
    post :create, :is_valid_time0=>"true", :participant0=>{"radiate_multicast"=>"0", "fec"=>"0", "role"=>"interactive", "machine_id"=>"3", "description"=>"", "machine_id_connected_to"=>"0"}, :accomplished0=>"false", :event=>{"name"=>"aaaaaaaa", "service"=>"meeting.act", "description"=>"aass", "password"=>"aa", "quality"=>"512K"}, :los_indices=>"1", :is_valid_participant0=>"true", :datetime0=>{"end_date(3i)"=>"14", "end_date(4i)"=>"13", "end_date(5i)"=>"51", "start_date(1i)"=>"2017", "start_date(2i)"=>"11", "start_date(3i)"=>"13", "start_date(4i)"=>"11", "start_date(5i)"=>"51", "end_date(1i)"=>"2017", "end_date(2i)"=>"11"}
    assert flash[:notice].include?('bigger')
    assert_redirected_to :action => "show"
  end
  
  
   
  def test_create_good
    login_as("user_normal")
    post :create, :is_valid_time0=>"true", :participant0=>{"radiate_multicast"=>"0", "fec"=>"10", "role"=>"interactive", "machine_id"=>"1", "description"=>"", "machine_id_connected_to"=>"0"}, :accomplished0=>"false", :event=>{"name"=>"aaaaaaaa", "service"=>"meeting.act", "description"=>"aass", "password"=>"aa", "quality"=>"512K"}, :los_indices=>"1", :is_valid_participant0=>"true", :datetime0=>{"end_date(3i)"=>"14", "end_date(4i)"=>"13", "end_date(5i)"=>"51", "start_date(1i)"=>"2017", "start_date(2i)"=>"11", "start_date(3i)"=>"14", "start_date(4i)"=>"11", "start_date(5i)"=>"51", "end_date(1i)"=>"2017", "end_date(2i)"=>"11"}
    assert_equal 'Event was successfully created.', flash[:notice]
    assert_redirected_to :action => "show"
  end
  
  
  def test_create_good_2
    #con otros valores
    login_as("user_normal")
    post :create, :is_valid_time0=>"true", :participant0=>{"radiate_multicast"=>"1", "fec"=>"0", "role"=>"interactive", "machine_id"=>"1", "description"=>"", "machine_id_connected_to"=>"0"}, :accomplished0=>"false", :event=>{"name"=>"aaaaaaaa", "service"=>"meeting.act", "description"=>"aass", "password"=>"aa", "quality"=>"512K"}, :los_indices=>"1", :is_valid_participant0=>"true", :datetime0=>{"end_date(3i)"=>"14", "end_date(4i)"=>"13", "end_date(5i)"=>"51", "start_date(1i)"=>"2017", "start_date(2i)"=>"11", "start_date(3i)"=>"14", "start_date(4i)"=>"11", "start_date(5i)"=>"51", "end_date(1i)"=>"2017", "end_date(2i)"=>"11"}
    assert_equal 'Event was successfully created.', flash[:notice]
    assert_redirected_to :action => "show"
  end
  
  
  def test_create_good_3
    #con otros valores
    login_as("user_normal")
    post :create, :is_valid_time0=>"true", :participant0=>{"radiate_multicast"=>"0", "fec"=>"0", "role"=>"FlowServer", "machine_id"=>"1", "description"=>"", "machine_id_connected_to"=>"0"},:participant1=>{"radiate_multicast"=>"1", "fec"=>"25", "role"=>"mcu", "machine_id"=>"2", "description"=>"Descrip", "machine_id_connected_to"=>"1"}, :accomplished0=>"false", :event=>{"name"=>"aaaaaaaa", "service"=>"meeting.act", "description"=>"aass", "password"=>"aa", "quality"=>"512K"}, :los_indices=>"1", :is_valid_participant0=>"true",:is_valid_participant1=>"true", :datetime0=>{"end_date(3i)"=>"14", "end_date(4i)"=>"13", "end_date(5i)"=>"51", "start_date(1i)"=>"2017", "start_date(2i)"=>"11", "start_date(3i)"=>"14", "start_date(4i)"=>"11", "start_date(5i)"=>"51", "end_date(1i)"=>"2017", "end_date(2i)"=>"11"}
    assert_equal 'Event was successfully created.', flash[:notice]
    assert_redirected_to :action => "show"
  end
  
  
  def test_create_good_integer_values
    #con valores numericos en vez de strings
    login_as("user_normal")
    post :create, :is_valid_time0=>"true", :participant0=>{"radiate_multicast"=>0, "fec"=>10, "role"=>"interactive", "machine_id"=>1, "description"=>"", "machine_id_connected_to"=>0}, :accomplished0=>"false", :event=>{"name"=>"aaaaaaaa", "service"=>"meeting.act", "description"=>"aass", "password"=>"aa", "quality"=>"512K"}, :los_indices=>"1", :is_valid_participant0=>"true", :datetime0=>{"end_date(3i)"=>"14", "end_date(4i)"=>"13", "end_date(5i)"=>"51", "start_date(1i)"=>"2017", "start_date(2i)"=>"11", "start_date(3i)"=>"14", "start_date(4i)"=>"11", "start_date(5i)"=>"51", "end_date(1i)"=>"2017", "end_date(2i)"=>"11"}
    assert_equal 'Event was successfully created.', flash[:notice]
    assert_redirected_to :action => "show"
  end
  
  
  def test_create_good_2_datetimes
    login_as("user_normal")
    post :create, :is_valid_time0=>"true",:is_valid_time1=>"true", :participant0=>{"radiate_multicast"=>"1", "fec"=>"0", "role"=>"interactive", "machine_id"=>"1", "description"=>"", "machine_id_connected_to"=>"0"}, :accomplished0=>"false", :event=>{"name"=>"aaaaaaaa", "service"=>"meeting.act", "description"=>"aass", "password"=>"aa", "quality"=>"512K"}, :los_indices=>"1", :is_valid_participant0=>"true", :datetime0=>{"end_date(3i)"=>"14", "end_date(4i)"=>"13", "end_date(5i)"=>"51", "start_date(1i)"=>"2017", "start_date(2i)"=>"11", "start_date(3i)"=>"14", "start_date(4i)"=>"11", "start_date(5i)"=>"51", "end_date(1i)"=>"2017", "end_date(2i)"=>"11"}, :datetime1=>{"end_date(3i)"=>"14", "end_date(4i)"=>"13", "end_date(5i)"=>"51", "start_date(1i)"=>"2018", "start_date(2i)"=>"11", "start_date(3i)"=>"14", "start_date(4i)"=>"11", "start_date(5i)"=>"51", "end_date(1i)"=>"2018", "end_date(2i)"=>"11"}
    assert_equal 'Event was successfully created.', flash[:notice]
    assert_redirected_to :action => "show"
  end
  
  
  def test_create_good_3_years_long
    #evento que dura 3 años
    login_as("user_normal")
    post :create, :is_valid_time0=>"true", :participant0=>{"radiate_multicast"=>"0", "fec"=>"0", "role"=>"FlowServer", "machine_id"=>"1", "description"=>"", "machine_id_connected_to"=>"0"},:participant1=>{"radiate_multicast"=>"1", "fec"=>"25", "role"=>"mcu", "machine_id"=>"2", "description"=>"Descrip", "machine_id_connected_to"=>"1"}, :accomplished0=>"false", :event=>{"name"=>"aaaaaaaa", "service"=>"meeting.act", "description"=>"aass", "password"=>"aa", "quality"=>"512K"}, :los_indices=>"1", :is_valid_participant0=>"true",:is_valid_participant1=>"true", :datetime0=>{"end_date(3i)"=>"14", "end_date(4i)"=>"13", "end_date(5i)"=>"51", "start_date(1i)"=>"2017", "start_date(2i)"=>"11", "start_date(3i)"=>"14", "start_date(4i)"=>"11", "start_date(5i)"=>"51", "end_date(1i)"=>"2017", "end_date(2i)"=>"11"}
    assert_equal 'Event was successfully created.', flash[:notice]
    assert_redirected_to :action => "show"
  end
  
  
  def test_create_with_error_in_participants    
    login_as("user_normal")
    post :create, :is_valid_time0=>"true", :participant0=>{"radiate_multicast"=>"0", "fec"=>"0", "role"=>"FlowServer", "machine_id"=>"1", "description"=>"", "machine_id_connected_to"=>"0"},:participant1=>{"radiate_multicast"=>"1", "fec"=>"25", "role"=>"mcu", "machine_id"=>"2", "description"=>"Descrip", "machine_id_connected_to"=>"2"}, :accomplished0=>"false", :event=>{"name"=>"aaaaaaaa", "service"=>"meeting.act", "description"=>"aass", "password"=>"aa", "quality"=>"512K"}, :los_indices=>"1", :is_valid_participant0=>"true",:is_valid_participant1=>"true", :datetime0=>{"end_date(3i)"=>"14", "end_date(4i)"=>"13", "end_date(5i)"=>"51", "start_date(1i)"=>"2017", "start_date(2i)"=>"11", "start_date(3i)"=>"14", "start_date(4i)"=>"11", "start_date(5i)"=>"51", "end_date(1i)"=>"2019", "end_date(2i)"=>"11"}
    assert_response :success
    assert @response.body.include?("errors")
    assert @response.body.include?("Participants")
  end
  
  
  def test_create_with_error_in_participants_2
    login_as("user_normal")
    post :create, :is_valid_time0=>"true", :participant0=>{"radiate_multicast"=>"0", "fec"=>"0", "role"=>"FlowServer", "machine_id"=>"1", "description"=>"", "machine_id_connected_to"=>"0"},:participant1=>{"radiate_multicast"=>"1", "fec"=>"25", "role"=>"mcu", "machine_id"=>"2", "description"=>"Descrip", "machine_id_connected_to"=>"3"}, :accomplished0=>"false", :event=>{"name"=>"aaaaaaaa", "service"=>"meeting.act", "description"=>"aass", "password"=>"aa", "quality"=>"512K"}, :los_indices=>"1", :is_valid_participant0=>"true",:is_valid_participant1=>"true", :datetime0=>{"end_date(3i)"=>"14", "end_date(4i)"=>"13", "end_date(5i)"=>"51", "start_date(1i)"=>"2017", "start_date(2i)"=>"11", "start_date(3i)"=>"14", "start_date(4i)"=>"11", "start_date(5i)"=>"51", "end_date(1i)"=>"2017", "end_date(2i)"=>"11"}
    #now i am not redirected
    assert_response :success
    assert @response.body.include?("errors")
    assert @response.body.include?("Participants")
  end
  
  
  def test_create_with_error_in_participants_3
    login_as("user_normal")
    post :create, :is_valid_time0=>"true", :participant0=>{"radiate_multicast"=>"0", "fec"=>"0", "role"=>"FlowServer", "machine_id"=>"1", "description"=>"", "machine_id_connected_to"=>"0"},:participant1=>{"radiate_multicast"=>"1", "fec"=>"25", "role"=>"mcu", "machine_id"=>"2", "description"=>"Descrip", "machine_id_connected_to"=>"3"}, :accomplished0=>"false", :event=>{"name"=>"aaaaaaaa", "service"=>"meeting.act", "description"=>"aass", "password"=>"aa", "quality"=>"512K"}, :los_indices=>"1", :is_valid_participant0=>"true",:is_valid_participant1=>"true", :datetime0=>{"end_date(3i)"=>"14", "end_date(4i)"=>"13", "end_date(5i)"=>"51", "start_date(1i)"=>"2017", "start_date(2i)"=>"11", "start_date(3i)"=>"14", "start_date(4i)"=>"11", "start_date(5i)"=>"51", "end_date(1i)"=>"2017", "end_date(2i)"=>"11"}
    #now i am not redirected
    assert_response :success
    assert @response.body.include?("errors")
    assert @response.body.include?("Participants")
  end
  
  
  def test_create_with_error_in_participants_4
    login_as("user_normal")
    post :create, :is_valid_time0=>"true", :participant0=>{"radiate_multicast"=>"0", "fec"=>"0", "role"=>"FlowServer", "machine_id"=>"1", "description"=>"", "machine_id_connected_to"=>"0"},:participant1=>{"radiate_multicast"=>"1", "fec"=>"25", "role"=>"mcu", "machine_id"=>"1", "description"=>"Descrip", "machine_id_connected_to"=>"0"}, :accomplished0=>"false", :event=>{"name"=>"aaaaaaaa", "service"=>"meeting.act", "description"=>"aass", "password"=>"aa", "quality"=>"512K"}, :los_indices=>"1", :is_valid_participant0=>"true",:is_valid_participant1=>"true", :datetime0=>{"end_date(3i)"=>"14", "end_date(4i)"=>"13", "end_date(5i)"=>"51", "start_date(1i)"=>"2017", "start_date(2i)"=>"11", "start_date(3i)"=>"14", "start_date(4i)"=>"11", "start_date(5i)"=>"51", "end_date(1i)"=>"2017", "end_date(2i)"=>"11"}
    #now i am not redirected
    assert_response :success
    assert @response.body.include?("errors")
    assert @response.body.include?("Participants")
  end
  
  
  def test_create_with_error_in_participants_5
    login_as("user_normal")
    post :create, :is_valid_time0=>"true", :participant0=>{"radiate_multicast"=>"0", "fec"=>"0", "role"=>"FlowServer", "machine_id"=>"1", "description"=>"", "machine_id_connected_to"=>"0"},:participant1=>{"radiate_multicast"=>"1", "fec"=>"25", "role"=>"mcu", "machine_id"=>"2", "description"=>"Descrip", "machine_id_connected_to"=>"3"},:event_participant2=>{"radiate_multicast"=>"1", "fec"=>"25", "role"=>"mcu", "machine_id"=>"3", "description"=>"Descrip", "machine_id_connected_to"=>"2"}, :accomplished0=>"false", :event=>{"name"=>"aaaaaaaa", "service"=>"meeting.act", "description"=>"aass", "password"=>"aa", "quality"=>"512K"}, :los_indices=>"1", :is_valid_participant0=>"true",:is_valid_participant1=>"true", :is_valid_participant2=>"true", :datetime0=>{"end_date(3i)"=>"14", "end_date(4i)"=>"13", "end_date(5i)"=>"51", "start_date(1i)"=>"2017", "start_date(2i)"=>"11", "start_date(3i)"=>"14", "start_date(4i)"=>"11", "start_date(5i)"=>"51", "end_date(1i)"=>"2017", "end_date(2i)"=>"11"}
    #now i am not redirected
    assert_response :success
    assert @response.body.include?("errors")
    assert @response.body.include?("Participants")
  end
  
      
  def test_create_with_error_in_datetimes
    login_as("user_normal")
    post :create, :is_valid_time0=>"true", :participant0=>{"radiate_multicast"=>"0", "fec"=>"0", "role"=>"FlowServer", "machine_id"=>"1", "description"=>"", "machine_id_connected_to"=>"0"}, :accomplished0=>"false", :event=>{"name"=>"aaaaaaaa", "service"=>"meeting.act", "description"=>"aass", "password"=>"aa", "quality"=>"512K"}, :los_indices=>"1", :is_valid_participant0=>"true", :datetime0=>{"end_date(3i)"=>"14", "end_date(4i)"=>"13", "end_date(5i)"=>"51", "start_date(1i)"=>"2017", "start_date(2i)"=>"11", "start_date(3i)"=>"14", "start_date(4i)"=>"11", "start_date(5i)"=>"51", "end_date(1i)"=>"2007", "end_date(2i)"=>"11"}
    #now i am not redirected
    assert_response :success
    assert @response.body.include?("errors")
    assert @response.body.include?("Participants")
  end    
      
  
  def test_create_with_error_in_datetimes_2
    login_as("user_normal")
    post :create, :is_valid_time0=>"true", :participant0=>{"radiate_multicast"=>"0", "fec"=>"0", "role"=>"FlowServer", "machine_id"=>"1", "description"=>"", "machine_id_connected_to"=>"0"}, :accomplished0=>"false", :event=>{"name"=>"aaaaaaaa", "service"=>"meeting.act", "description"=>"aass", "password"=>"aa", "quality"=>"512K"}, :los_indices=>"1", :is_valid_participant0=>"true", :datetime0=>{"end_date(3i)"=>"14", "end_date(4i)"=>"13", "end_date(5i)"=>"51", "start_date(1i)"=>"2017", "start_date(2i)"=>"11", "start_date(3i)"=>"14", "start_date(4i)"=>"11", "start_date(5i)"=>"51", "end_date(1i)"=>"2007", "end_date(2i)"=>"11"}
    #now i am not redirected
    assert_response :success
  end
  
  
  def test_create_with_error_in_datetimes_3
    login_as("user_normal")
    post :create, :is_valid_time0=>"true", :is_valid_time1=>"true", :event_participant0=>{"radiate_multicast"=>"0", "fec"=>"0", "role"=>"FlowServer", "resource_id"=>"1", "description"=>"", "resource_id_connected_to"=>"0"}, :accomplished0=>"false", :event=>{"name"=>"aaaaaaaa", "service"=>"meeting.act", "description"=>"aass", "password"=>"aa", "quality"=>"512K"}, :los_indices=>"1", :is_valid_participant0=>"true", :datetime0=>{"end_date(3i)"=>"14", "end_date(4i)"=>"13", "end_date(5i)"=>"51", "start_date(1i)"=>"2017", "start_date(2i)"=>"11", "start_date(3i)"=>"14", "start_date(4i)"=>"11", "start_date(5i)"=>"51", "end_date(1i)"=>"2017", "end_date(2i)"=>"11"}, :datetime1=>{"end_date(3i)"=>"14", "end_date(4i)"=>"13", "end_date(5i)"=>"51", "start_date(1i)"=>"2017", "start_date(2i)"=>"11", "start_date(3i)"=>"14", "start_date(4i)"=>"11", "start_date(5i)"=>"51", "end_date(1i)"=>"2017", "end_date(2i)"=>"11"}
    #now i am not redirected
    assert_response :success
  end 
  
  
  def test_create_with_error_in_datetimes_4
    login_as("user_normal")
    post :create, :is_valid_time0=>"true", :event_participant0=>{"radiate_multicast"=>"0", "fec"=>"0", "role"=>"FlowServer", "resource_id"=>"1", "description"=>"", "resource_id_connected_to"=>"0"}, :accomplished0=>"false", :event=>{"name"=>"aaaaaaaa", "service"=>"meeting.act", "description"=>"aass", "password"=>"aa", "quality"=>"512K"}, :los_indices=>"1", :is_valid_participant0=>"true", :datetime0=>{"end_date(3i)"=>"14", "end_date(4i)"=>"13", "end_date(5i)"=>"51", "start_date(1i)"=>"2015", "start_date(2i)"=>"11", "start_date(3i)"=>"14", "start_date(4i)"=>"11", "start_date(5i)"=>"51", "end_date(1i)"=>"2015", "end_date(2i)"=>"11"}
    #now i am not redirected
    assert_response :success
  end
  
  
  def test_edit_with_no_resources
     login_as("user_no_resources") 
    post :edit
    assert flash[:notice].include?('no resources')
    assert_redirected_to :action => "index"  
  end
  
  
  def test_edit_an_event_that_is_not_mine
    login_as("user_normal")
    post :edit, :id=>1
    assert_equal 'Event not found.', flash[:notice]    
    assert_redirected_to :action => "index"  
  end
  
  
  def test_edit_good
    login_as("user_admin")
    post :edit, :id=>1
    assert_template "edit"  
  end
  
  
  def test_edit_good_2
    login_as("user_normal")
    post :edit, :id=>2
    assert_template "edit"    
  end

end
