require File.dirname(__FILE__) + '/../test_helper'

class EventsControllerTest < ActionController::TestCase
  include ActionController::AuthenticationTestHelper
  
#  fixtures   :event_datetimes, :events_users, :events, :machines_users, :machines, :participants, :profiles, :users, :spaces, :entries
#  
#  def setup
#    @controller = EventsController.new
#    @request    = ActionController::TestRequest.new
#    @response   = ActionController::TestResponse.new
#  end
#  
#  
#  #delete supereventomolon, that is the event manually created
#  def teardown
#    if evento = Event.find_by_name("supereventomolon")
#      evento.destroy
#    end
#  end
# 
# def test_search_admin
#    login_as("user_admin")
#    get :search, :space_id => 'Public'
#    assert_response :success
#    assert @response.body.include?("Search")
#    assert_template 'search'
#  end
#  
#  def test_search_no_login
#    
#    get :search, :space_id => 'Public'
#    assert_response :success
#    assert @response.body.include?("Search")
#    assert_template 'search'
#  end
#  def test_advanced_search
#    login_as("user_normal")
#    get :advanced_search, :space_id => 'Public'
#    assert_template 'advanced_search'
#    assert @response.body.include?("advanced")
#    assert_response :success
#  end
#  
#  def test_advanced_search_no_login
#    
#    get :advanced_search, :space_id => 'Public'
#    assert_template 'advanced_search'
#    assert @response.body.include?("advanced")
#    assert_response :success
#  end
#  
#  def test_title_search
#    login_as("user_normal")
#    get :title, :space_id => 'Public'
#    assert_template 'title'
#    assert @response.body.include?("title")
#    assert_response :success
#  end
#  
#  def test_description_search
#    login_as("user_normal")
#    get :description, :space_id => 'Public'
#    assert_template 'description'
#    assert @response.body.include?("description")
#    assert_response :success
#  end
#  
#  def test_dates_search
#    login_as("user_normal")
#    get :dates, :space_id => 'Public'
#    assert_template 'dates'
#    assert @response.body.include?("dates")
#    assert_response :success
#  end
#
#  
#  def test_clean
#    get :clean, :space_id => 'Public'
#    
#    
#    assert_response :success
#  end
#  
#  def test_search_events_1_found
#    login_as("user_normal")
#    post :search_events, :query=>'complejo', :space_id => 'Public'
#    assert_response :success
#    assert @response.body.include?(" events were found")
#    assert_template 'search_events'
#  end
#  
#  def test_search_events_0_found
#    login_as("user_normal")
#    post :search_events, :query=>'esternocleidomastoideo', :space_id => 'Public'
#    assert_response :success
#    assert @response.body.include?("0 events were found")
#    assert_template 'search_events'
#  end
#  
#  def test_search_by_tag
#    login_as("user_normal")
#    post :search_by_tag, :tags=>'imperial', :space_id => 'Public'
#    assert_response :success
#    #assert @response.body.include?("Title")
#    assert_template 'search_by_tag'
#  end
#  def test_advanced_search_events
#    login_as("user_normal")
#    post :advanced_search_events, :query=>'complejo', :space_id => 'Public'
#    assert_response :success
#    assert @response.body.include?("1 events were found")
#    assert_template 'search_events'
#    
#  end
#  
#  def test_advanced_search_events_0_found
#    login_as("user_normal")
#    post :advanced_search_events, :query=>'esternocleidomastoideo', :space_id => 'Public'
#    assert_response :success
#    assert @response.body.include?("0 events were found")
#    assert_template 'search_events'
#  end
#  
#  def test_search_by_title
#    login_as("user_normal")
#    post :search_by_title, :query=>'complejo', :space_id => 'Public'
#    assert_response :success
#    assert @response.body.include?("1 events were found")
#    assert_template 'search_events'
#    
#  end
#  def test_search_by_title_0_found
#    login_as("user_normal")
#    post :search_by_title, :query=>'esternocleidomastoideo', :space_id => 'Public'
#    assert_response :success
#    assert @response.body.include?("0 events were found")
#    assert_template 'search_events'
#  end
#  def test_search_by_description
#    login_as("user_normal")
#    post :search_in_description, :query=>'videoconferencia', :space_id => 'Public'
#    assert_response :success
#    
#    assert_template 'search_events'
#    
#  end
#  def test_search_by_description_0_found
#    login_as("user_normal")
#    post :search_in_description, :query=>'esternocleidomastoideo', :space_id => 'Public'
#    assert_response :success
#    assert @response.body.include?("0 events were found")
#    assert_template 'search_events'
#    
#  end
#  
#  def test_search_by_date
#    login_as("user_normal")
#    post :search_by_date, :query1=>'2008-02-20', :query2=>'2008-05-28', :space_id => 'Public'
#    assert_response :success
#    
#    assert_template 'search_events'
#  end
#  def test_search_by_date_wrong
#    login_as("user_normal")
#    post :search_by_date, :query1=>'2008-02-20', :query2=>'2008-02-10', :space_id => 'Public'
#    assert_response :success
#    assert flash[:notice].include?('first date cannot be lower')
#    assert_template 'search'
#  end
#  
end  
