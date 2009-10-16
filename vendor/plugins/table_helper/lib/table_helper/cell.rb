module TableHelper
  # Represents a single cell within a table.  This can either be a regular
  # data cell (td) or a header cell (th).  By default, all cells will have
  # their name appended to the cell's class attribute.
  # 
  # == Examples
  # 
  #   # Data cell
  #   c = Cell.new(:author, 'John Doe')
  #   c.html    # => <td class="author">John Doe</td>
  #   
  #   # Header cell
  #   c = Cell.new(:author, 'Author Name')
  #   c.content_type = :header
  #   c.html
  #   
  #   # With namespace
  #   c = Cell.new(:author, :namespace => 'post')
  #   c.content_type = :header
  #   c.html    # => <td class="post-author">Author</td>
  class Cell < HtmlElement
    # The css class to apply to empty cells
    cattr_accessor :empty_class
    @@empty_class = 'ui-state-empty'
    
    # The content to display within the cell
    attr_reader :content
    
    # The type of content this cell represents (:data or :header)
    attr_reader :content_type
    
    def initialize(name, content = name.to_s.titleize, html_options = {}) #:nodoc
      html_options, content = content, name.to_s.titleize if content.is_a?(Hash)
      namespace = html_options.delete(:namespace)
      super(html_options)
      
      @content = content.to_s
      
      if name
        name = "#{namespace}-#{name}" unless namespace.blank?
        self[:class] = "#{self[:class]} #{name}".strip
      end
      self[:class] = "#{self[:class]} #{empty_class}".strip if content.blank?
      
      self.content_type = :data
    end
    
    # Indicates what type of content will be stored in this cell.  This can
    # be set to either :data or :header.
    def content_type=(value)
      raise ArgumentError, "content_type must be set to :data or :header, was: #{value.inspect}" unless [:data, :header].include?(value)
      @content_type = value
    end
    
    private
      def tag_name
        @content_type == :data ? 'td' : 'th'
      end
  end
end
