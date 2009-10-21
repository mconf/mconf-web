module TableHelper
  # Represents an HTML element
  # 
  # == Modifying HTML options
  # 
  # HTML options can normally be specified when creating the element.
  # However, if they need to be modified after the element has been created,
  # you can access the properties like so:
  # 
  #   r = Row.new
  #   r[:style] = 'display: none;'
  # 
  # or for a cell:
  # 
  #   c = Cell.new
  #   c[:style] = 'display: none;'
  class HtmlElement
    include ActionView::Helpers::TagHelper
    
    delegate :[], :[]=, :to => '@html_options'
    
    def initialize(html_options = {}) #:nodoc:
      @html_options = html_options.symbolize_keys
    end
    
    # Generates the html representing this element
    def html
      content_tag(tag_name, content, @html_options)
    end
    
    private
      # The name of the element tag to use (e.g. td, th, tr, etc.)
      def tag_name
        ''
      end
      
      # The content that will be displayed inside of the tag
      def content
        ''
      end
  end
end
