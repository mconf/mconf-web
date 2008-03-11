require File.dirname(__FILE__) + '/../test_helper'

class TaggingTest < Test::Unit::TestCase
  fixtures :tags, :taggings, :users, :events
  def setup
    @objs = Event.find(:all, :limit => 2)
    
    @obj1 = @objs[0]
    @obj1.tag_with("pale")
    @obj1.reload
    
    @obj2 = @objs[1]
    @obj2.tag_with("pale imperial")
    @obj2.reload
    
    @obj3 = User.find(:first)
    @tag1 = Tag.find(1)  
    @tag2 = Tag.find(2)  
    @tagging1 = Tagging.find(1)
  end

  def test_tag_with
    @obj2.tag_with "hoppy pilsner"
    assert_equal "hoppy pilsner", @obj2.tag_list
  end
  
  def test_find_tagged_with
    @obj1.tag_with "seasonal lager ipa"
    @obj2.tag_with ["lager", "stout", "fruity", "seasonal"]
    
    result1 = [@obj1]
    assert_equal Event.tagged_with("ipa"), result1
    assert_equal Event.tagged_with("ipa lager"), result1
    assert_equal Event.tagged_with("ipa", "lager"), result1
    
    result2 = [@obj1.id, @obj2.id].sort
    assert_equal Event.tagged_with("seasonal").map(&:id).sort, result2
    assert_equal Event.tagged_with("seasonal lager").map(&:id).sort, result2
    assert_equal Event.tagged_with("seasonal", "lager").map(&:id).sort, result2
  end
  
  def test__add_tags
    @obj1._add_tags "porter longneck"
    assert Tag.find_by_name("porter").taggables.include?(@obj1)
    assert Tag.find_by_name("longneck").taggables.include?(@obj1)
    assert_equal "longneck pale porter", @obj1.tag_list    
    
    @obj1._add_tags [2]
    assert_equal "imperial longneck pale porter", @obj1.tag_list        
  end
  
  def test__remove_tags
    @obj2._remove_tags ["2", @tag1]
    assert @obj2.tags.empty?
  end
  
  def test_tag_list
    assert_equal "imperial pale", @obj2.tag_list
  end
    
  def test_taggable
    assert_raises(RuntimeError) do 
      @tagging1.send(:taggable?, true) 
    end
    assert !@tagging1.send(:taggable?)
    assert @obj3.send(:taggable?)
    
  end
    
end
