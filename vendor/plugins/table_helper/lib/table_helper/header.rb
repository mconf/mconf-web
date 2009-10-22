require 'table_helper/row'

module TableHelper
  # Represents the header of the table.  In HTML, you can think of this as
  # the <thead> tag of the table.
  class Header < HtmlElement
    # The table this header is a part of
    attr_reader :table
    
    # The actual header row
    attr_reader :row
    
    # Whether or not the header should be hidden when the collection is
    # empty.  Default is true.
    attr_accessor :hide_when_empty
    
    delegate :empty?, :to => :row
    
    # Creates a new header for the given table.
    # 
    # If the class is known, then the header will be pre-filled with
    # the columns defined in that class (assuming it's an ActiveRecord
    # class).
    def initialize(table)
      super()
      
      @table = table
      @row = Row.new(self)
      @hide_when_empty = true
      
      # If we know what class the objects in the collection are and we can
      # figure out what columns are defined in that class, then we can
      # pre-fill the header with those columns so that the user doesn't
      # have to
      klass = table.klass
      if klass && klass.respond_to?(:column_names)
        if !table.empty? && klass < ActiveRecord::Base
          # Make sure only the attributes that have been loaded are used
          column_names = table.collection.first.attributes.keys
        else
          # Assume all attributes are loaded
          column_names = klass.column_names
        end
        
        column(*column_names.map(&:to_sym))
      end
      
      @customized = false
    end
    
    # The current columns in this header, in the order in which they will be
    # built
    def columns
      row.cells
    end
    
    # Gets the names of all of the columns being displayed in the table
    def column_names
      row.cell_names
    end
    
    # Clears all of the current columns from the header
    def clear
      row.clear
    end
    
    # Creates one or more to columns in the header.  This will clear any
    # pre-existing columns if it is being customized for the first time after
    # it was initially created.
    def column(*names)
      # Clear the header row if this is being customized by the user
      unless @customized
        @customized = true
        clear
      end
      
      # Extract configuration
      options = names.last.is_a?(Hash) ? names.pop : {}
      content = names.last.is_a?(String) ? names.pop : nil
      args = [content, options].compact
      
      names.collect! do |name|
        column = row.cell(name, *args)
        column.content_type = :header
        column[:scope] ||= 'col'
        column
      end
      
      names.length == 1 ? names.first : names
    end
    
    # Creates and returns the generated html for the header
    def html
      html_options = @html_options.dup
      html_options[:style] = 'display: none;' if table.empty? && hide_when_empty
      
      content_tag(tag_name, content, html_options)
    end
    
    private
      def tag_name
        'thead'
      end
      
      def content
        @row.html
      end
  end
end
