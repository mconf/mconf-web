require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class BodyByDefaultTest < Test::Unit::TestCase
  def setup
    @table = TableHelper::CollectionTable.new([])
    @body = TableHelper::Body.new(@table)
  end
  
  def test_should_have_a_table
    assert_equal @table, @body.table
  end
  
  def test_should_not_alternate
    assert_nil @body.alternate
  end
  
  def test_should_have_an_empty_caption
    assert_equal 'No matches found.', @body.empty_caption
  end
end

class BodyTest < Test::Unit::TestCase
  def setup
    @table = TableHelper::CollectionTable.new([])
    @body = TableHelper::Body.new(@table)
  end
  
  def test_should_raise_exception_if_invalid_alternate_specified
    assert_raise(ArgumentError) {@body.alternate = :invalid}
  end
  
  def test_should_not_raise_exception_for_odd_alternate
    assert_nothing_raised {@body.alternate = :odd}
    assert_equal :odd, @body.alternate
  end
  
  def test_should_not_raise_exception_for_even_alternate
    assert_nothing_raised {@body.alternate = :even}
    assert_equal :even, @body.alternate
  end
end

class BodyWithEmptyCollectionTest < Test::Unit::TestCase
  def setup
    @table = TableHelper::CollectionTable.new([])
    @body = TableHelper::Body.new(@table)
  end
  
  def test_should_have_no_content_if_no_empty_caption
    @body.empty_caption = nil
    assert_html_equal '<tbody></tbody>', @body.html
  end
  
  def test_should_show_content_if_empty_caption
    expected = <<-end_str
      <tbody>
        <tr class="ui-collection-empty">
          <td>No matches found.</td>
        </tr>
      </tbody>
    end_str
    assert_html_equal expected, @body.html
  end
  
  def test_should_use_custom_empty_caption_class_if_specified
    original_empty_caption_class = TableHelper::Body.empty_caption_class
    TableHelper::Body.empty_caption_class = 'ui-collection-empty_caption'
    
    expected = <<-end_str
      <tbody>
        <tr class="ui-collection-empty_caption">
          <td>No matches found.</td>
        </tr>
      </tbody>
    end_str
    assert_html_equal expected, @body.html
  ensure
    TableHelper::Body.empty_caption_class = original_empty_caption_class
  end
  
  def test_should_set_colspan_if_header_has_multiple_columns
    @table.header :title, :author_name
    
    expected = <<-end_str
      <tbody>
        <tr class="ui-collection-empty">
          <td colspan="2">No matches found.</td>
        </tr>
      </tbody>
    end_str
    assert_html_equal expected, @body.html
  end
end

class BodyWithCollectionTest < Test::Unit::TestCase
  class Post
    attr_accessor :title
    
    def initialize(title)
      @title = title
    end
  end
  
  def setup
    @collection = [Post.new('first'), Post.new('second'), Post.new('last')]
    @table = TableHelper::CollectionTable.new(@collection)
    @table.header :title
    
    @body = TableHelper::Body.new(@table)
  end
  
  def test_should_build_row_using_object_location_for_default_index
    build_post = nil
    index = nil
    @body.each {|row, build_post, index|}
    
    @collection.each do |post|
      html = @body.build_row(post) 
      assert_equal post, build_post
      assert_equal @collection.index(post), index
      
      expected = <<-end_str
        <tr class="post ui-collection-result">
          <td class="post-title">#{post.title}</td>
        </tr>
      end_str
      assert_html_equal expected, html
    end
  end
  
  def test_should_build_row_using_custom_value_for_index
    post = nil
    index = nil
    @body.each {|row, post, index|}
    
    html = @body.build_row(@collection.first, 1)
    assert_equal @collection.first, post
    assert_equal 1, index
    
    expected = <<-end_str
      <tr class="post ui-collection-result">
        <td class="post-title">first</td>
      </tr>
    end_str
    assert_html_equal expected, html
  end
  
  def test_should_build_row_with_missing_cells
    header = @table.header :author_name
    
    expected = <<-end_str
      <tr class="post ui-collection-result">
        <td class="post-title">first</td>
        <td class="post-author_name ui-state-empty"></td>
      </tr>
    end_str
    assert_html_equal expected, @body.build_row(@collection.first)
  end
  
  def test_should_build_html
    expected = <<-end_str
      <tbody>
        <tr class="post ui-collection-result">
          <td class="post-title">first</td>
        </tr>
        <tr class="post ui-collection-result">
          <td class="post-title">second</td>
        </tr>
        <tr class="post ui-collection-result">
          <td class="post-title">last</td>
        </tr>
      </tbody>
    end_str
    assert_html_equal expected, @body.html
  end
  
  def test_should_include_custom_attributes_in_body_tag
    @body[:class] = 'pretty'
    
    expected = <<-end_str
      <tbody class="pretty">
        <tr class="post ui-collection-result">
          <td class="post-title">first</td>
        </tr>
        <tr class="post ui-collection-result">
          <td class="post-title">second</td>
        </tr>
        <tr class="post ui-collection-result">
          <td class="post-title">last</td>
        </tr>
      </tbody>
    end_str
    assert_html_equal expected, @body.html
  end
end

class BodyWithCustomBuilderTest < Test::Unit::TestCase
  def setup
    @collection = [Object.new, Object.new, Object.new]
    @table = TableHelper::CollectionTable.new(@collection)
    @table.header :index
    
    @body = TableHelper::Body.new(@table)
    @body.each do |row, object, index|
      row.index index.to_s
    end
  end
  
  def test_should_use_custom_builder
    expected = <<-end_str
      <tbody>
        <tr class="object ui-collection-result">
          <td class="object-index">0</td>
        </tr>
        <tr class="object ui-collection-result">
          <td class="object-index">1</td>
        </tr>
        <tr class="object ui-collection-result">
          <td class="object-index">2</td>
        </tr>
      </tbody>
    end_str
    assert_html_equal expected, @body.html
  end
end

class BodyWithAlternatingEvenRowsTest < Test::Unit::TestCase
  class Post
    attr_accessor :title
    
    def initialize(title)
      @title = title
    end
  end
  
  def setup
    @collection = [Post.new('first'), Post.new('second'), Post.new('last')]
    table = TableHelper::CollectionTable.new(@collection)
    table.header :title
    
    @body = TableHelper::Body.new(table)
    @body.alternate = :even
  end
  
  def test_should_alternate_even_row
    expected = <<-end_str
      <tr class="post ui-collection-result ui-state-alternate">
        <td class="post-title">first</td>
      </tr>
    end_str
    assert_html_equal expected, @body.build_row(@collection.first)
  end
  
  def test_should_not_alternate_odd_row
    expected = <<-end_str
      <tr class="post ui-collection-result">
        <td class="post-title">second</td>
      </tr>
    end_str
    assert_html_equal expected, @body.build_row(@collection[1])
  end
end

class BodyWithAlternatingOddRowsTest < Test::Unit::TestCase
  class Post
    attr_accessor :title
    
    def initialize(title)
      @title = title
    end
  end
  
  def setup
    @collection = [Post.new('first'), Post.new('second'), Post.new('last')]
    table = TableHelper::CollectionTable.new(@collection)
    table.header :title
    
    @body = TableHelper::Body.new(table)
    @body.alternate = :odd
  end
  
  def test_should_alternate_odd_row
    expected = <<-end_str
      <tr class="post ui-collection-result ui-state-alternate">
        <td class="post-title">second</td>
      </tr>
    end_str
    assert_html_equal expected, @body.build_row(@collection[1])
  end
  
  def test_should_not_alternate_even_row
    expected = <<-end_str
      <tr class="post ui-collection-result">
        <td class="post-title">first</td>
      </tr>
    end_str
    assert_html_equal expected, @body.build_row(@collection.first)
  end
end
