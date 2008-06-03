require File.dirname(__FILE__) + '/../test_helper'

class RoleTest < ActiveSupport::TestCase
  fixtures :cms_roles
  
  # Replace this with your real tests.
  def test_name
    role = cms_roles(:operator_name_repeated)
    assert role.valid?
    #assert_equal "has already been taken", role.errors.on(:name)
  end
end
