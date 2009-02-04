require File.dirname(__FILE__) + '/../test_helper'

class MachinesControllerTest < ActionController::TestCase
  include ActionController::AuthenticationTestHelper
  
  fixtures   :event_datetimes, :events_users, :events, :machines_users, :machines, :participants, :profiles, :users, :spaces, :entries
  
  def setup
    @controller = MachinesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new    
    login_as("user_admin")
    @space = spaces(:espacio_1)
  end
  
  
  def test_should_get_index
    get :index, :space_id => @space.name
    assert_response :success
    assert_not_nil assigns(:machines)
  end

  def test_should_create_machine
    assert_difference('Machine.count') do
      post :create, :machine => {:name => "uno", :nickname => "dos"}
    end

    assert_redirected_to machines_path()
  end

  def test_should_update_machine
    put :update, :id => machines(:machine_triton).id, :machine => { }
    assert_redirected_to machines_path
  end

  def test_should_destroy_machine
    assert_difference('Machine.count', -1) do
      delete :destroy, :id => machines(:machine_triton).id
    end

    assert_redirected_to machines_path
  end
end
