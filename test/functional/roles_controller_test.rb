require File.dirname(__FILE__) + '/../test_helper'

class RolesControllerTest < ActionController::TestCase
 
    include CMS::AuthenticationTestHelper

  fixtures :users, :cms_performances, :cms_roles
   def test_index_admin
     login_as("user_admin")
  get :index
  assert_response :success
  assert_template "index"
   end
end
