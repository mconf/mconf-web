require File.dirname(__FILE__) + '/../test_helper'

class ArticlesControllerTest < ActionController::TestCase

  def test_index
    get :index
    assert :success
  end
end
