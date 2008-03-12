require File.dirname(__FILE__) + '/../test_helper'

class TaggingTest < Test::Unit::TestCase
  fixtures :tags, :taggings, :users, :events
  def default_test
    assert true
  end
    
end
