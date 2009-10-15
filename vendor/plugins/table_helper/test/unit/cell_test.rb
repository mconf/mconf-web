require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class CellByDefaultTest < Test::Unit::TestCase
  def setup
    @cell = TableHelper::Cell.new(:name)
  end
  
  def test_should_have_content
    assert_equal 'Name', @cell.content
  end
  
  def test_should_have_a_content_type
    assert_equal :data, @cell.content_type
  end
  
  def test_should_have_a_class_name
    assert_equal 'name', @cell[:class]
  end
  
  def test_should_build_html
    assert_equal '<td class="name">Name</td>', @cell.html
  end
end

class CellTest < Test::Unit::TestCase
  def test_should_raise_exception_if_content_type_is_invalid
    assert_raise(ArgumentError) {TableHelper::Cell.new(:name).content_type = :invalid}
  end
end

class CellWithCustomContentTest < Test::Unit::TestCase
  def setup
    @cell = TableHelper::Cell.new(:name, 'John Smith')
  end
  
  def test_should_use_custom_content
    assert_equal 'John Smith', @cell.content
  end
end

class CellWithEmptyContentTest < Test::Unit::TestCase
  def setup
    @cell = TableHelper::Cell.new(:name, nil)
  end
  
  def test_should_include_empty_class
    assert_equal 'name ui-state-empty', @cell[:class]
  end
  
  def test_should_use_custom_empty_class_if_specified
    original_empty_class = TableHelper::Cell.empty_class
    TableHelper::Cell.empty_class = 'ui-state-blank'
    
    cell = TableHelper::Cell.new(:name, nil)
    assert_equal 'name ui-state-blank', cell[:class]
  ensure
    TableHelper::Cell.empty_class = original_empty_class
  end
  
  def test_should_build_html
    assert_equal '<td class="name ui-state-empty"></td>', @cell.html
  end
end

class CellWithCustomHtmlOptionsTest < Test::Unit::TestCase
  def setup
    @cell = TableHelper::Cell.new(:name, :style => 'float: left;')
  end
  
  def test_should_include_custom_options
    assert_equal 'float: left;', @cell[:style]
  end
  
  def test_should_build_html
    assert_equal '<td class="name" style="float: left;">Name</td>', @cell.html
  end
  
  def test_should_append_automated_class_name_if_class_already_specified
    cell = TableHelper::Cell.new(:name, :class => 'selected')
    assert_equal 'selected name', cell[:class]
    assert_equal '<td class="selected name">Name</td>', cell.html
  end
end

class CellWithCustomContentAndHtmlOptionsTest < Test::Unit::TestCase
  def setup
    @cell = TableHelper::Cell.new(:name, 'John Smith', :style => 'float: left;')
  end
  
  def test_should_use_custom_content
    assert_equal 'John Smith', @cell.content
  end
  
  def test_should_include_custom_options
    assert_equal 'float: left;', @cell[:style]
  end
  
  def test_should_build_html
    assert_equal '<td class="name" style="float: left;">John Smith</td>', @cell.html
  end
end

class CellWithNamespaceTest < Test::Unit::TestCase
  def setup
    @cell = TableHelper::Cell.new(:name, :namespace => 'post')
  end
  
  def test_should_namespace_class
    assert_equal 'post-name', @cell[:class]
  end
end

class CellWithHeaderContentType < Test::Unit::TestCase
  def setup
    @cell = TableHelper::Cell.new(:name)
    @cell.content_type = :header
  end
  
  def test_should_have_a_content_type
    assert_equal :header, @cell.content_type
  end
  
  def test_should_build_a_header_cell
    assert_equal '<th class="name">Name</th>', @cell.html
  end
end
