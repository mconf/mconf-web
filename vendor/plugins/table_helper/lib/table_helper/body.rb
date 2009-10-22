require 'table_helper/body_row'

module TableHelper
  # Represents the body of the table.  In HTML, you can think of this as
  # the <tbody> tag of the table.
  class Body < HtmlElement
    # The css class to apply for all rows in the body
    cattr_accessor :empty_caption_class
    @@empty_caption_class = 'ui-collection-empty'
    
    # The table this body is a part of
    attr_reader :table
    
    # If set to :odd or :even, every odd or even-numbered row will have the
    # alternate class appended to its html attributes. Default is nil.
    attr_accessor :alternate
    
    # The caption to display in the collection is empty
    attr_accessor :empty_caption
    
    def initialize(table) #:nodoc:
      super()
      
      @table = table
      @empty_caption = 'No matches found.'
    end
    
    def alternate=(value) #:nodoc:
      raise ArgumentError, 'alternate must be set to :odd or :even' if value && ![:odd, :even].include?(value)
      @alternate = value
    end
    
    # Builds the body of the table.  This includes the actual data that is
    # generated for each object in the collection.
    # 
    # +each+ expects a block that defines the data in each cell.  Each
    # iteration of the block will provide the row within the table, the object
    # being rendered, and the index of the object.  For example,
    # 
    #   t.rows.each do |row, post, index|
    #     row.title     "<div class=\"wrapped\">#{post.title}</div>"
    #     row.category  post.category.name
    #   end
    # 
    # In addition, to specifying the data, you can also modify the html
    # options of the row.  For more information on doing this, see the
    # BodyRow class.
    # 
    # If the collection is empty and +empty_caption+ is set on the body,
    # then the actual body will be replaced by a single row containing the
    # html that was stored in +empty_caption+.
    # 
    # == Default Values
    # 
    # Whenever possible, the default value of a cell will be set to the
    # object's attribute with the same name as the cell.  For example,
    # if a Post consists of the attribute +title+, then the cell for the
    # title will be prepopulated with that attribute's value:
    # 
    #   t.rows.each do |row, post index|
    #     row.title post.title
    #   end
    # 
    # <tt>row.title</tt> is already set to post.category so there's no need to
    # manually set the value of that cell.  However, it is always possible
    # to override the default value like so:
    # 
    #   t.rows.each do |row, post, index|
    #     row.title     link_to(post.title, post_url(post))
    #     row.category  post.category.name
    #   end
    def each(&block)
      @builder = block
    end
    
    # Builds a row for an object in the table.
    # 
    # The provided block should set the values for each cell in the row.
    def build_row(object, index = table.collection.index(object))
      row = BodyRow.new(object, self)
      row.alternate = alternate ? index.send("#{alternate}?") : false
      @builder.call(row.builder, object, index) if @builder
      row.html
    end
    
    private
      def tag_name
        'tbody'
      end
      
      def content
        content = ''
        
        if table.empty? && @empty_caption
          # No objects to display
          row = Row.new(self)
          row[:class] = empty_caption_class
          
          html_options = {}
          html_options[:colspan] = table.header.columns.size if table.header.columns.size > 1
          row.cell nil, @empty_caption, html_options
          
          content << row.html
        else
          table.collection.each_with_index do |object, i|
            content << build_row(object, i)
          end
        end
        
        content
      end
  end
end
