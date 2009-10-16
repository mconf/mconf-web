require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class HtmlElementByDefaultTest < Test::Unit::TestCase
  def setup
    @element = TableHelper::HtmlElement.new
  end
  
  def test_should_generate_an_empty_tag
    assert_equal '<></>', @element.html
  end
  
  def test_not_have_any_html_options
    element = TableHelper::HtmlElement.new
    assert_nil element[:class]
  end
end

class HtmlElementTest < Test::Unit::TestCase
  class DivElement < TableHelper::HtmlElement
    def tag_name
      'div'
    end
  end
  
  def test_should_set_html_options_on_initialization
    element = TableHelper::HtmlElement.new(:class => 'fancy')
    assert_equal 'fancy', element[:class]
  end
  
  def test_should_symbolize_html_options
    element = TableHelper::HtmlElement.new('class' => 'fancy')
    assert_equal 'fancy', element[:class]
  end
  
  def test_should_generate_entire_element_if_content_and_tag_name_specified
    element = DivElement.new
    element.instance_eval do
      def content
        'hello world'
      end
    end
    
    assert_equal '<div>hello world</div>', element.html
  end
  
  def test_should_include_html_options_in_element_tag
    element = DivElement.new
    element[:class] = 'fancy'
    
    assert_equal '<div class="fancy"></div>', element.html
  end
  
  def test_should_save_changes_in_html_options
    element = TableHelper::HtmlElement.new
    element[:float] = 'left'
    assert_equal 'left', element[:float]
  end
end

class HtmlElementWithNoContentTest < Test::Unit::TestCase
  class DivElement < TableHelper::HtmlElement
    def tag_name
      'div'
    end
  end
  
  def setup
    @element = DivElement.new
  end
  
  def test_should_generate_empty_tags
    assert_equal '<div></div>', @element.html
  end
end
