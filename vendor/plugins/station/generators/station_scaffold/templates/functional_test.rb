require File.dirname(__FILE__) + '<%= '/..' * class_nesting_depth %>/../test_helper'

class <%= controller_class_name %>ControllerTest < ActionController::TestCase

  def test_index
    get :index
    assert :success
  end
end
