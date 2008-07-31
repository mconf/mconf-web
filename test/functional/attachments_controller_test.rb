require File.dirname(__FILE__) + '/../test_helper'

class AttachmentsControllerTest < ActionController::TestCase

  def test_index
    get :index
    assert :success
  end
end
