require File.dirname(__FILE__) + '/../test_helper'

include AuthenticatedTestHelper

class EventsControllerTest < ActionController::TestCase
  
  #A non authenticated user should be redirected to create a new session and the message is "Please log in"
  def test_get_index_should_be_redirected
    get :index
    assert_redirected_to :controller => "sessions", :action => "new"
    assert_equal "Please log in", flash[:notice]
  end

  def test_login
    login_as("admin")
    
  end
  

end
