require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class RowBuilderParent < TableHelper::HtmlElement
  attr_reader :table
  
  def initialize(table = TableHelper::CollectionTable.new([]))
    @table = table
  end
end

class RowBuilderByDefaultTest < Test::Unit::TestCase
  def setup
    @row = TableHelper::Row.new(RowBuilderParent.new)
    @builder = TableHelper::RowBuilder.new(@row)
  end
  
  def test_should_forward_missing_calls_to_row
    assert_equal '<tr></tr>', @builder.html
  end
end

class RowBuilderWithCellsTest < Test::Unit::TestCase
  def setup
    @row = TableHelper::Row.new(RowBuilderParent.new)
    @builder = TableHelper::RowBuilder.new(@row)
    @builder.define_cell('first-name')
  end
  
  def test_should_create_cell_reader
    assert @builder.respond_to?(:first_name)
  end
  
  def test_should_read_cell_without_arguments
    cell = @row.cells['first-name'] = TableHelper::Cell.new('first-name')
    assert_equal cell, @builder.first_name
  end
  
  def test_should_write_cell_with_arguments
    cell = @builder.first_name 'Your Name'
    assert_equal 'Your Name', cell.content
  end
end

class RowBuilderAfterUndefiningACellTest < Test::Unit::TestCase
  def setup
    @row = TableHelper::Row.new(RowBuilderParent.new)
    @builder = TableHelper::RowBuilder.new(@row)
    @builder.define_cell('first-name')
    @builder.undef_cell('first-name')
  end
  
  def test_should_not_have_cell_reader
    assert_raise(NoMethodError) {@builder.first_name}
  end
end
