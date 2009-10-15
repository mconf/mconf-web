require 'table_helper/html_element'
require 'table_helper/header'
require 'table_helper/body'
require 'table_helper/footer'

module TableHelper
  # Represents a table that displays data for multiple objects within a
  # collection.
  class CollectionTable < HtmlElement
    # The css class to apply for all menu bars
    cattr_accessor :collection_class
    @@collection_class = 'ui-collection'
    
    # The class of objects that will be rendered in the table
    attr_reader :klass
    
    # The name of the objects in the collection.  By default, this is the
    # underscored name of the class of objects being rendered.  This value is
    # used for generates parts of the css classes in the table, such as rows
    # and cells.
    # 
    # For example, if the class is Post, then the object name will be "post".
    attr_accessor :object_name
    
    # The actual collection of objects being rendered in the table's body.
    # This collection will also be used to help automatically determine what
    # the class is.
    attr_reader :collection
    
    # The body of rows that will be generated for each object in the
    # collection.  The actual content for each row and the html options can
    # be configured as well.
    # 
    # See TableHelper::Body for more information.
    # 
    # == Examples
    # 
    #   # Defining rows
    #   t.rows.each do |row, post, index|
    #     row.category post.category.name
    #     row.author   post.author.name
    #     ...
    #     row[:style] = 'margin-top: 5px;'
    #   end
    #   
    #   # Customizing html options
    #   t.rows[:class] = 'pretty'
    attr_reader :rows
    
    # Creates a new table based on the objects within the given collection
    def initialize(collection, klass = nil, html_options = {}) #:nodoc:
      html_options, klass = klass, nil if klass.is_a?(Hash)
      super(html_options)
      
      @collection = collection
      @klass = klass || default_class
      @object_name = @klass ? @klass.name.split('::').last.underscore : nil
      @html_options.reverse_merge!(:cellspacing => '0', :cellpadding => '0')
      
      self[:class] = "#{self[:class]} #{@object_name.pluralize}".strip if @object_name
      self[:class] = "#{self[:class]} #{collection_class}".strip
      
      # Build actual content
      @header = Header.new(self)
      @rows = Body.new(self)
      @footer = Footer.new(self)
      
      yield self if block_given?
    end
    
    # Will any rows be generated in the table's body?
    def empty?
      collection.empty?
    end
    
    # Creates a new header cell with the given name.  Headers must be defined
    # in the order in which they will be rendered.
    # 
    # The actual caption and html options for the header can be configured
    # as well.  The caption determines what will be displayed in each cell.
    # 
    # == Examples
    # 
    #   # Adding headers
    #   t.header :title                                   # => <th class="post-title">Title</th>
    #   t.header :title, 'The Title'                      # => <th class="post-title">The Title</th>
    #   t.header :title, :class => 'pretty'               # => <th class="post-title pretty">Title</th>
    #   t.header :title, 'The Title', :class => 'pretty'  # => <th class="post-title pretty">The Title</th>
    #   
    #   # Customizing html options
    #   t.header[:class] = 'pretty'
    def header(*args)
      args.empty? ? @header : @header.column(*args)
    end
    
    # Creates a new footer cell with the given name.  Footers must be defined
    # in the order in which they will be rendered.
    # 
    # The actual caption and html options for the footer can be configured
    # as well.  The caption determines what will be displayed in each cell.
    # 
    # == Examples
    # 
    #   # Adding footers
    #   t.footer :total                         # => <td class="post-total"></th>
    #   t.footer :total, 5                      # => <td class="post-total">5</th>
    #   t.footer :total, :class => 'pretty'     # => <td class="post-total pretty"></th>
    #   t.footer :total, 5, :class => 'pretty'  # => <td class="post-total pretty">5</th>
    #   
    #   # Customizing html options
    #   t.footer[:class] = 'pretty'
    def footer(*args)
      args.empty? ? @footer : @footer.cell(*args)
    end
    
    private
      # Finds the class representing the objects within the collection
      def default_class
        if collection.respond_to?(:proxy_reflection)
          collection.proxy_reflection.klass
        elsif !collection.empty?
          collection.first.class
        end
      end
      
      def tag_name
        'table'
      end
      
      def content
        content = ''
        content << @header.html unless @header.empty?
        content << @rows.html
        content << @footer.html unless @footer.empty?
        content
      end
  end
end
