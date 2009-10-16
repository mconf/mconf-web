require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class CollectionTableByDefaultTest < Test::Unit::TestCase
  def setup
    @collection = []
    @table = TableHelper::CollectionTable.new(@collection)
  end
  
  def test_cellspacing_should_be_zero
    assert_equal '0', @table[:cellspacing]
  end
  
  def test_cellpadding_should_be_zero
    assert_equal '0', @table[:cellpadding]
  end
  
  def test_should_have_a_css_class
    assert_equal 'ui-collection', @table[:class]
  end
  
  def test_should_use_custom_collection_css_class_if_specified
    original_collection_class = TableHelper::CollectionTable.collection_class
    TableHelper::CollectionTable.collection_class = 'ui-records'
    
    table = TableHelper::CollectionTable.new(@collection)
    assert_equal 'ui-records', table[:class]
  ensure
    TableHelper::CollectionTable.collection_class = original_collection_class
  end
  
  def test_should_not_have_a_klass
    assert_nil @table.klass
  end
  
  def test_should_not_have_an_object_name
    assert_nil @table.object_name
  end
  
  def test_should_have_a_collection
    assert_equal @collection, @table.collection
  end
  
  def test_should_have_a_header
    assert_not_nil @table.header
    assert_instance_of TableHelper::Header, @table.header
  end
  
  def test_should_have_a_body
    assert_not_nil @table.rows
    assert_instance_of TableHelper::Body, @table.rows
  end
  
  def test_should_have_a_footer
    assert_not_nil @table.footer
    assert_instance_of TableHelper::Footer, @table.footer
  end
  
  def test_should_be_empty
    assert @table.empty?
  end
end

class CollectionTableTest < Test::Unit::TestCase
  def test_should_accept_block_with_self_as_argument
    args = nil
    table = TableHelper::CollectionTable.new([]) {|*args|}
    
    assert_equal [table], args
  end
end

class CollectionTableWithClassDetectionTest < Test::Unit::TestCase
  class Post
  end
  
  class Reflection
    def klass
      Post
    end
  end
  
  class PostCollection < Array
    def proxy_reflection
      Reflection.new
    end
  end
  
  def test_should_not_detect_class_if_collection_is_empty_vanilla_array
    table = TableHelper::CollectionTable.new([])
    assert_nil table.klass
  end
  
  def test_should_detect_class_if_collection_has_objects
    table = TableHelper::CollectionTable.new([Post.new])
    assert_equal Post, table.klass
  end
  
  def test_should_detect_class_if_collection_is_model_proxy
    table = TableHelper::CollectionTable.new(PostCollection.new)
    assert_equal Post, table.klass
  end
end

class CollectionTableWithClassTest < Test::Unit::TestCase
  class Post
  end
  
  def setup
    @table = TableHelper::CollectionTable.new([], Post)
  end
  
  def test_should_have_klass
    assert_equal Post, @table.klass
  end
  
  def test_should_have_object_name
    assert_equal 'post', @table.object_name
  end
  
  def test_should_include_pluralized_object_name_in_css_class
    assert_equal 'posts ui-collection', @table[:class]
  end
end

class CollectionTableWithEmptyCollectionTest < Test::Unit::TestCase
  def setup
    @table = TableHelper::CollectionTable.new([])
  end
  
  def test_should_be_empty
    assert @table.empty?
  end
  
  def test_should_build_html
    expected = <<-end_str
      <table cellpadding="0" cellspacing="0" class="ui-collection">
        <tbody>
          <tr class="ui-collection-empty"><td>No matches found.</td></tr>
        </tbody>
      </table>
    end_str
    assert_html_equal expected, @table.html
  end
end

class CollectionTableWithObjectsTest < Test::Unit::TestCase
  def setup
    @table = TableHelper::CollectionTable.new([Object.new])
  end
  
  def test_should_not_be_empty
    assert !@table.empty?
  end
end

class CollectionTableHeaderTest < Test::Unit::TestCase
  def setup
    @table = TableHelper::CollectionTable.new([Object.new])
  end
  
  def test_should_not_include_in_html_if_none_specified
    expected = <<-end_str
      <table cellpadding="0" cellspacing="0" class="objects ui-collection">
        <tbody>
          <tr class="object ui-collection-result"></tr>
        </tbody>
      </table>
    end_str
    assert_html_equal expected, @table.html
  end
  
  def test_should_include_in_html_if_specified
    @table.header :name, :title
    
    expected = <<-end_str
      <table cellpadding="0" cellspacing="0" class="objects ui-collection">
        <thead>
          <tr>
            <th class="object-name" scope="col">Name</th>
            <th class="object-title" scope="col">Title</th>
          </tr>
        </thead>
        <tbody>
          <tr class="object ui-collection-result">
            <td class="object-name ui-state-empty"></td>
            <td class="object-title ui-state-empty"></td>
          </tr>
        </tbody>
      </table>
    end_str
    assert_html_equal expected, @table.html
  end
end

class CollectionTableFooterTest < Test::Unit::TestCase
  def setup
    @table = TableHelper::CollectionTable.new([Object.new])
  end
  
  def test_should_not_include_in_html_if_none_specified
    expected = <<-end_str
      <table cellpadding="0" cellspacing="0" class="objects ui-collection">
        <tbody>
          <tr class="object ui-collection-result"></tr>
        </tbody>
      </table>
    end_str
    assert_html_equal expected, @table.html
  end
  
  def test_should_include_in_html_if_specified
    @table.footer :total, 1
    
    expected = <<-end_str
      <table cellpadding="0" cellspacing="0" class="objects ui-collection">
        <tbody>
          <tr class="object ui-collection-result"></tr>
        </tbody>
        <tfoot>
          <tr>
            <td class="object-total">1</td>
          </tr>
        </tfoot>
      </table>
    end_str
    assert_html_equal expected, @table.html
  end
end
