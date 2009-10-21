require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class FooterByDefaultTest < Test::Unit::TestCase
  def setup
    @table = TableHelper::CollectionTable.new([])
    @footer = TableHelper::Footer.new(@table)
  end
  
  def test_should_hide_when_empty
    assert @footer.hide_when_empty
  end
  
  def test_should_be_empty
    assert @footer.empty?
  end
  
  def test_should_have_a_row
    assert_not_nil @footer.row
  end
  
  def test_should_have_a_table
    assert_equal @table, @footer.table
  end
end

class FooterTest < Test::Unit::TestCase
  def setup
    table = TableHelper::CollectionTable.new([Object.new])
    @footer = TableHelper::Footer.new(table)
  end
  
  def test_should_include_custom_attributes
    @footer[:class] = 'pretty'
    
    expected = <<-end_str
      <tfoot class="pretty">
        <tr>
        </tr>
      </tfoot>
    end_str
    assert_html_equal expected, @footer.html
  end
end

class FooterWithCellsTest < Test::Unit::TestCase
  def setup
    @table = TableHelper::CollectionTable.new([Object.new])
    @footer = TableHelper::Footer.new(@table)
    @cell = @footer.cell :total, 20
  end
  
  def test_should_namespace_cell_classes
    assert_equal 'object-total', @cell[:class]
  end
  
  def test_should_build_html
    expected = <<-end_str
      <tfoot>
        <tr>
          <td class="object-total">20</td>
        </tr>
      </tfoot>
    end_str
    assert_html_equal expected, @footer.html
  end
  
  def test_should_include_colspan_if_more_headers_than_footers
    @table.header :title, :name, :value
    
    expected = <<-end_str
      <tfoot>
        <tr>
          <td class="object-total" colspan="3">20</td>
        </tr>
      </tfoot>
    end_str
    assert_html_equal expected, @footer.html
  end
end

class FooterWithEmptyCollectionTest < Test::Unit::TestCase
  def setup
    table = TableHelper::CollectionTable.new([])
    @footer = TableHelper::Footer.new(table)
  end
 
  def test_should_not_display_if_hide_when_empty
    @footer.hide_when_empty = true
    
    expected = <<-end_str
      <tfoot style="display: none;">
        <tr>
        </tr>
      </tfoot>
    end_str
    assert_html_equal expected, @footer.html
  end
  
  def test_should_display_if_not_hide_when_empty
    @footer.hide_when_empty = false
    
    expected = <<-end_str
      <tfoot>
        <tr>
        </tr>
      </tfoot>
    end_str
    assert_html_equal expected, @footer.html
  end
end
