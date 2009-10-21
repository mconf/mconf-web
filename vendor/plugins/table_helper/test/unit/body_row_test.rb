require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class BodyRowByDefaultTest < Test::Unit::TestCase
  def setup
    table = TableHelper::CollectionTable.new([])
    @header = TableHelper::Header.new(table)
    @row = TableHelper::BodyRow.new(Object.new, @header)
  end
  
  def test_should_have_a_parent
    assert_equal @header, @row.parent
  end
  
  def test_should_not_alternate
    assert !@row.alternate
  end
  
  def test_should_have_a_class_name
    assert_equal 'ui-collection-result', @row[:class]
  end
  
  def test_should_use_custom_result_class_if_specified
    original_result_class = TableHelper::BodyRow.result_class
    TableHelper::BodyRow.result_class = 'ui-collection-item'
    
    row = TableHelper::BodyRow.new(Object.new, @header)
    assert_equal 'ui-collection-item', row[:class]
  ensure
    TableHelper::BodyRow.result_class = original_result_class
  end
end

class BodyRowTest < Test::Unit::TestCase
  class Post
    def title
      'Default Value'
    end
  end
  
  def setup
    table = TableHelper::CollectionTable.new([])
    header = table.header
    header.column :title
    
    @row = TableHelper::BodyRow.new(Post.new, header)
  end
  
  def test_should_generate_cell_accessors
    assert_nothing_raised {@row.builder.title}
  end
  
  def test_should_override_default_cell_content_if_cell_specified
    @row.builder.title 'Hello World'
    assert_equal '<tr class="ui-collection-result"><td class="title">Hello World</td></tr>', @row.html
  end
end

class BodyRowWithTableObjectNameTest < Test::Unit::TestCase
  def setup
    table = TableHelper::CollectionTable.new([], Object)
    header = table.header
    
    @row = TableHelper::BodyRow.new(Object.new, header)
  end
  
  def test_should_include_object_name_in_class
    assert_equal 'object ui-collection-result', @row[:class]
  end
end

class BodyRowWithNoColumnsTest < Test::Unit::TestCase
  def setup
    table = TableHelper::CollectionTable.new([])
    header = table.header
    
    @row = TableHelper::BodyRow.new(Object.new, header)
  end
  
  def test_should_not_build_cells
    assert_equal '<tr class="ui-collection-result"></tr>', @row.html
  end
end

class BodyRowWithCustomAttributeTest < Test::Unit::TestCase
  class Post
    def title
      'Default Value'
    end
  end
  
  def setup
    table = TableHelper::CollectionTable.new([])
    header = table.header
    header.column :title
    header.column :author_name
    
    @row = TableHelper::BodyRow.new(Post.new, header)
  end
  
  def test_should_use_attribute_values_as_cell_content
    @row.builder.author_name 'John Doe'
    assert_equal '<tr class="ui-collection-result"><td class="title">Default Value</td><td class="author_name">John Doe</td></tr>', @row.html
  end
end

class BodyRowWithMissingCellsTest < Test::Unit::TestCase
  def setup
    table = TableHelper::CollectionTable.new([])
    header = table.header
    header.column :title
    header.column :author_name
    
    @row = TableHelper::BodyRow.new(Object.new, header)
  end
  
  def test_should_build_missing_cells_if_cells_not_specified
    assert_equal '<tr class="ui-collection-result"><td class="title ui-state-empty"></td><td class="author_name ui-state-empty"></td></tr>', @row.html
  end
  
  def test_should_skip_missing_cells_if_colspan_replaces_missing_cells
    @row.builder.title 'Hello World', :colspan => 2
    assert_equal '<tr class="ui-collection-result"><td class="title" colspan="2">Hello World</td></tr>', @row.html
  end
  
  def test_should_not_skip_missing_cells_if_colspan_doesnt_replace_missing_cells
    @row.builder.title 'Hello World'
    assert_equal '<tr class="ui-collection-result"><td class="title">Hello World</td><td class="author_name ui-state-empty"></td></tr>', @row.html
  end
end

class BodyRowAlternatingTest < Test::Unit::TestCase
  def setup
    table = TableHelper::CollectionTable.new([])
    @header = table.header
    
    @row = TableHelper::BodyRow.new(Object.new, @header)
    @row.alternate = true
  end
  
  def test_should_add_alternate_class
    assert_equal '<tr class="ui-collection-result ui-state-alternate"></tr>', @row.html
  end
  
  def test_should_use_custom_altenrate_class_if_specified
    original_alternate_class = TableHelper::BodyRow.alternate_class
    TableHelper::BodyRow.alternate_class = 'ui-row-alternate'
    
    row = TableHelper::BodyRow.new(Object.new, @header)
    row.alternate = true
    
    assert_equal '<tr class="ui-collection-result ui-row-alternate"></tr>', @row.html
  ensure
    TableHelper::BodyRow.alternate_class = original_alternate_class
  end
end
