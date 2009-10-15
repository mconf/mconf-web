require 'table_helper/row'

module TableHelper
  # Represents the header of the table.  In HTML, you can think of this as
  # the <tfoot> tag of the table.
  class Footer < HtmlElement
    # The table this footer is a part of
    attr_reader :table
    
    # The actual footer row
    attr_reader :row
    
    # Whether or not the footer should be hidden when the collection is
    # empty.  Default is true.
    attr_accessor :hide_when_empty
    
    delegate :cell, :empty?, :to => :row
    
    def initialize(table) #:nodoc:
      super()
      
      @table = table
      @row = Row.new(self)
      @hide_when_empty = true
    end
    
    def html #:nodoc:
      # Force the last cell to span the remaining columns
      cells = row.cells.values
      colspan = table.header.columns.length - cells[0..-2].inject(0) {|count, (name, cell)| count += (cell[:colspan] || 1).to_i}
      cells.last[:colspan] ||= colspan if colspan > 1
      
      html_options = @html_options.dup
      html_options[:style] = "display: none; #{html_options[:style]}".strip if table.empty? && hide_when_empty
      
      content_tag(tag_name, content, html_options)
    end
    
    private
      def tag_name
        'tfoot'
      end
      
      # Generates the html for the footer.  The footer generally consists of a
      # summary of the data in the body.  This row will be wrapped inside of
      # a tfoot tag.  If the collection is empty and hide_when_empty was set
      # to true, then the footer will be hidden.
      def content
        @row.html
      end
  end
end
