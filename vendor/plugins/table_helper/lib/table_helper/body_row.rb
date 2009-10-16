require 'table_helper/row'

module TableHelper
  # Represents a single row within the body of a table.  The row can consist
  # of either data cells or header cells. 
  # 
  # == Alternating rows
  # 
  # Alternating rows can be automated by setting the +alternate+ property.
  # For example,
  # 
  #   r = BodyRow.new(object, parent)
  #   r.alternate = true
  class BodyRow < Row
    # The css class to apply for all rows in the body
    cattr_accessor :result_class
    @@result_class = 'ui-collection-result'
    
    # The css class to apply for rows that are marked as "alternate"
    cattr_accessor :alternate_class
    @@alternate_class = 'ui-state-alternate'
    
    # True if this is an alternating row, otherwise false.  Default is false.
    attr_accessor :alternate
    
    def initialize(object, parent) #:nodoc:
      super(parent)
      
      @alternate = false
      self[:class] = "#{self[:class]} #{table.object_name} #{result_class}".strip
      
      # For each column defined in the table, see if we can prepopulate the
      # cell based on the data in the object.  If not, we can at least
      # provide shortcut accessors to the cell
      table.header.column_names.each do |column|
        value = object.respond_to?(column) ? object.send(column) : nil
        cell(column, value)
      end
    end
    
    # Generates the html for this row in additional to the border row
    # (if specified)
    def html
      original_options = @html_options.dup
      self[:class] = "#{self[:class]} #{alternate_class}".strip if alternate
      html = super
      @html_options = original_options
      html
    end
    
    private
      # Builds the row's cells based on the order of the columns in the
      # header.  If a cell cannot be found for a specific column, then a blank
      # cell is rendered.
      def content
        number_to_skip = 0 # Keeps track of the # of columns to skip
        
        html = ''
        table.header.column_names.each do |column|
          number_to_skip -= 1 and next if number_to_skip > 0
          
          if cell = @cells[column]
            number_to_skip = (cell[:colspan] || 1) - 1
          else
            cell = Cell.new(column, nil)
          end
          
          html << cell.html
        end
        
        html
      end
  end
end
