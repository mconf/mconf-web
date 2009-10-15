require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class HeaderByDefaultTest < Test::Unit::TestCase
  def setup
    @table = TableHelper::CollectionTable.new([])
    @header = TableHelper::Header.new(@table)
  end
  
  def test_should_hide_when_empty
    assert @header.hide_when_empty
  end
  
  def test_should_have_no_columns
    expected = {}
    assert_equal expected, @header.columns
  end
  
  def test_should_have_no_column_names
    assert_equal [], @header.column_names
  end
  
  def test_should_be_empty
    assert @header.empty?
  end
  
  def test_should_have_a_row
    assert_not_nil @header.row
  end
  
  def test_should_have_a_table
    assert_equal @table, @header.table
  end
end

class HeaderWithColumnDetectionTest < Test::Unit::TestCase
  class Post
    def self.column_names
      ['title', 'author_name']
    end
  end
  
  def test_should_have_columns_if_class_has_column_names
    table = TableHelper::CollectionTable.new([], Post)
    header = TableHelper::Header.new(table)
    
    assert_equal ['title', 'author_name'], header.column_names
  end
  
  def test_should_not_have_columns_if_class_has_no_column_names
    table = TableHelper::CollectionTable.new([], Array)
    header = TableHelper::Header.new(table)
    
    assert header.columns.empty?
  end
end

class HeaderWithAutomaticColumnsTest < Test::Unit::TestCase
  class Post
    def self.column_names
      ['title', 'author_name']
    end
  end
  
  def setup
    table = TableHelper::CollectionTable.new([Post.new], Post)
    @header = TableHelper::Header.new(table)
  end
  
  def test_should_use_titleized_name_for_content
    assert_equal 'Title', @header.columns['title'].content
    assert_equal 'Author Name', @header.columns['author_name'].content
  end
  
  def test_should_namespace_html_classes
    assert_equal 'post-title', @header.columns['title'][:class]
    assert_equal 'post-author_name', @header.columns['author_name'][:class]
  end
  
  def test_should_not_be_empty
    assert !@header.empty?
  end
  
  def test_should_build_html
    expected = <<-end_str
      <thead>
        <tr>
          <th class="post-title" scope="col">Title</th>
          <th class="post-author_name" scope="col">Author Name</th>
        </tr>
      </thead>
    end_str
    assert_html_equal expected, @header.html
  end
  
  def test_should_clear_existing_columns_when_first_column_is_created
    cell = @header.column :created_on
    
    assert_raise(NoMethodError) {@header.builder.title}
    assert_raise(NoMethodError) {@header.builder.author_name}
    
    expected = {'created_on' => cell}
    assert_equal expected, @header.columns
  end
end

class HeaderWithCustomColumnsTest < Test::Unit::TestCase
  def setup
    table = TableHelper::CollectionTable.new([])
    @header = TableHelper::Header.new(table)
    @title = @header.column :title
  end
  
  def test_should_set_scope
    assert_equal 'col', @title[:scope]
  end
  
  def test_should_use_name_for_default_content
    assert_equal 'Title', @title.content
  end
  
  def test_should_allow_content_to_be_customized
    title = @header.column :title, 'The Title'
    assert_equal 'The Title', title.content
  end
  
  def test_should_allow_html_options_to_be_customized
    title = @header.column :title, :class => 'pretty'
    assert_equal 'pretty title', title[:class]
  end
  
  def test_should_not_be_empty
    assert !@header.empty?
  end
end

class HeaderWithMultipleColumnsTest < Test::Unit::TestCase
  def setup
    table = TableHelper::CollectionTable.new([])
    @header = TableHelper::Header.new(table)
    @title, @author_name = @header.column :title, :author_name, :class => 'pretty'
  end
  
  def test_should_use_default_content_for_each
    assert_equal 'Title', @title.content
    assert_equal 'Author Name', @author_name.content
  end
  
  def test_should_share_html_options
    assert_equal 'pretty title', @title[:class]
  end
end

class HeaderWithEmptyCollectionTest < Test::Unit::TestCase
  def setup
    table = TableHelper::CollectionTable.new([])
    @header = TableHelper::Header.new(table)
  end
  
  def test_should_not_display_if_hide_when_empty
    @header.hide_when_empty = true
    
    expected = <<-end_str
      <thead style="display: none;">
        <tr>
        </tr>
      </thead>
    end_str
    assert_html_equal expected, @header.html
  end
  
  def test_should_display_if_not_hide_when_empty
    @header.hide_when_empty = false
    
    expected = <<-end_str
      <thead>
        <tr>
        </tr>
      </thead>
    end_str
    assert_html_equal expected, @header.html
  end
end

class HeaderWithCollectionTest < Test::Unit::TestCase
  def setup
    table = TableHelper::CollectionTable.new([Object.new])
    @header = TableHelper::Header.new(table)
    @header.column :title, :author_name
  end
  
  def test_should_display_if_hide_when_empty
    @header.hide_when_empty = true
    
    expected = <<-end_str
      <thead>
        <tr>
          <th class="object-title" scope="col">Title</th>
          <th class="object-author_name" scope="col">Author Name</th>
        </tr>
      </thead>
    end_str
    assert_html_equal expected, @header.html
  end
  
  def test_should_display_if_not_hide_when_empty
    @header.hide_when_empty = false
    
    expected = <<-end_str
      <thead>
        <tr>
          <th class="object-title" scope="col">Title</th>
          <th class="object-author_name" scope="col">Author Name</th>
        </tr>
      </thead>
    end_str
    assert_html_equal expected, @header.html
  end
end

class HeaderWithCustomHtmlOptionsTest < Test::Unit::TestCase
  def setup
    table = TableHelper::CollectionTable.new([Object.new])
    @header = TableHelper::Header.new(table)
    @header.column :title
  end
  
  def test_should_include_html_options
    @header[:class] = 'pretty'
    
    expected = <<-end_str
      <thead class="pretty">
        <tr>
          <th class="object-title" scope="col">Title</th>
        </tr>
      </thead>
    end_str
    assert_html_equal expected, @header.html
  end
  
  def test_should_include_html_options_for_header_row
    @header.row[:class] = 'pretty'
    
    expected = <<-end_str
      <thead>
        <tr class="pretty">
          <th class="object-title" scope="col">Title</th>
        </tr>
      </thead>
    end_str
    assert_html_equal expected, @header.html
  end
end

class HeaderWithModelsTest < ActiveRecord::TestCase
  def setup
    Person.create(:first_name => 'John', :last_name => 'Smith')
  end
  
  def test_should_include_all_columns_if_not_selecting_columns
    table = TableHelper::CollectionTable.new(Person.all)
    @header = TableHelper::Header.new(table)
    assert_equal %w(first_name id last_name), @header.column_names.sort
  end
  
  def test_should_only_include_selected_columns_if_specified_in_query
    table = TableHelper::CollectionTable.new(Person.all(:select => 'first_name'))
    @header = TableHelper::Header.new(table)
    assert_equal %w(first_name), @header.column_names.sort
  end
end
