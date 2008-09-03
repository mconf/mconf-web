require 'test_helper'

class GroupsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:groups)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_group
    assert_difference('Group.count') do
      post :create, :group => { }
    end

    assert_redirected_to group_path(assigns(:group))
  end

  def test_should_show_group
    get :show, :id => groups(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => groups(:one).id
    assert_response :success
  end

  def test_should_update_group
    put :update, :id => groups(:one).id, :group => { }
    assert_redirected_to group_path(assigns(:group))
  end

  def test_should_destroy_group
    assert_difference('Group.count', -1) do
      delete :destroy, :id => groups(:one).id
    end

    assert_redirected_to groups_path
  end
end
