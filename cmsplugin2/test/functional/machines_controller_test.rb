require 'test_helper'

class MachinesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:machines)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_machine
    assert_difference('Machine.count') do
      post :create, :machine => { }
    end

    assert_redirected_to machine_path(assigns(:machine))
  end

  def test_should_show_machine
    get :show, :id => machines(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => machines(:one).id
    assert_response :success
  end

  def test_should_update_machine
    put :update, :id => machines(:one).id, :machine => { }
    assert_redirected_to machine_path(assigns(:machine))
  end

  def test_should_destroy_machine
    assert_difference('Machine.count', -1) do
      delete :destroy, :id => machines(:one).id
    end

    assert_redirected_to machines_path
  end
end
