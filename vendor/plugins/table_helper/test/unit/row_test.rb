require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class RowParent < TableHelper::HtmlElement
  attr_reader :table
  
  def initialize(table = TableHelper::CollectionTable.new([]))
    @table = table
  end
end

class RowByDefaultTest < Test::Unit::TestCase
  def setup
    @parent = RowParent.new
    @row = TableHelper::Row.new(@parent)
  end
  
  def test_should_not_have_class
    assert_nil @row[:class]
  end
  
  def test_should_not_have_any_cells
    assert @row.cells.empty?
  end
  
  def test_should_not_have_any_cell_names
    assert_equal [], @row.cell_names
  end
  
  def test_should_have_a_builder
    assert_not_nil @row.builder
  end
  
  def test_should_have_a_parent
    assert_equal @parent, @row.parent
  end
  
  def test_should_have_a_table
    assert_equal @parent.table, @row.table
  end
  
  def test_should_be_empty
    assert @row.empty?
  end
end

class RowWithoutCellsTest < Test::Unit::TestCase
  def setup
    @row = TableHelper::Row.new(RowParent.new)
  end
  
  def test_should_be_able_to_clear_cells
    @row.clear
    assert_equal [], @row.cell_names
  end
  
  def test_should_be_empty
    assert @row.empty?
  end
  
  def test_should_build_html
    assert_equal '<tr></tr>', @row.html
  end
end

class RowWithCellsTest < Test::Unit::TestCase
  def setup
    @row = TableHelper::Row.new(RowParent.new)
    @cell = @row.cell :name
  end
  
  def test_should_create_cell_reader
    assert_nothing_raised {@row.builder.name}
    assert_equal @cell, @row.builder.name
  end
  
  def test_should_use_cell_name_for_class_name
    assert_equal 'name', @cell[:class]
  end
  
  def test_should_have_cells
    expected = {'name' => @cell}
    assert_equal expected, @row.cells
  end
  
  def test_should_have_cell_names
    assert_equal ['name'], @row.cell_names
  end
  
  def test_should_not_be_empty
    assert !@row.empty?
  end
  
  def test_should_be_able_to_clear_existing_cells
    @row.clear
    
    assert_equal [], @row.cell_names
  end
  
  def test_should_build_html
    assert_equal '<tr><td class="name">Name</td></tr>', @row.html
  end
  
  def test_should_create_new_cell_if_cell_already_exists
    new_cell = @row.cell :name
    assert_not_same new_cell, @cell
  end
  
  def test_should_be_able_to_recreate_cell_after_clearing
    @row.clear
    @row.cell :name
    
    assert_equal ['name'], @row.cell_names
    assert_nothing_raised {@row.builder.name}
  end
  
  def test_should_allow_html_options
    @row.clear
    cell = @row.cell :name, 'Name', :class => 'pretty'
    
    assert_equal 'pretty name', cell[:class]
  end
end

class RowWithMultipleCellsTest < Test::Unit::TestCase
  def setup
    @row = TableHelper::Row.new(RowParent.new)
    @name = @row.cell :name
    @location = @row.cell :location
  end
  
  def test_should_have_cells
    expected = {'name' => @name, 'location' => @location}
    assert_equal expected, @row.cells
  end
  
  def test_should_have_cell_names
    assert_equal ['location', 'name'], @row.cell_names.sort
  end
  
  def test_should_build_html
    assert_equal '<tr><td class="name">Name</td><td class="location">Location</td></tr>', @row.html
  end
end

class RowWithUnconventionalCellNamesTest < Test::Unit::TestCase
  def setup
    @row = TableHelper::Row.new(RowParent.new)
    @cell = @row.cell 'the-name'
  end
  
  def test_should_have_cells
    expected = {'the-name' => @cell}
    assert_equal expected, @row.cells
  end
  
  def test_should_have_cell_names
    assert_equal ['the-name'], @row.cell_names
  end
  
  def test_should_use_sanitized_name_for_reader_method
    assert_nothing_raised {@row.builder.the_name}
    assert_equal @cell, @row.builder.the_name
  end
  
  def test_should_use_unsanitized_name_for_class
    assert_equal 'the-name', @cell[:class]
  end
end

class RowWithConflictingCellNamesTest < Test::Unit::TestCase
  def setup
    @row = TableHelper::Row.new(RowParent.new)
    @row.cell :id
  end
  
  def test_should_be_able_to_read_cell
    assert_instance_of TableHelper::Cell, @row.cells['id']
  end
  
  def test_should_be_able_to_write_to_cell
    @row.builder.id '1'
    assert_instance_of TableHelper::Cell, @row.cells['id']
  end
  
  def test_should_be_able_to_clear
    assert_nothing_raised {@row.clear}
  end
end

class RowWithTableObjectNameTest < Test::Unit::TestCase
  def setup
    table = TableHelper::CollectionTable.new([], Object)
    @row = TableHelper::Row.new(RowParent.new(table))
    @cell = @row.cell :id
  end
  
  def test_should_not_have_class
    assert_nil @row[:class]
  end
  
  def test_should_namespace_cell
    assert_equal 'object-id', @cell[:class]
  end
end
