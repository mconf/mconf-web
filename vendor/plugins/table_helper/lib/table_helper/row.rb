require 'table_helper/cell'

module TableHelper
  # Provides a blank class that can be used to build the cells for a row
  class RowBuilder < BlankSlate #:nodoc:
    reveal :respond_to?
    
    # Creates a builder for the given row
    def initialize(row)
      @row = row
    end
    
    # Proxies all missed methods to the row
    def method_missing(*args)
      @row.send(*args)
    end
    
    # Defines the builder method for the given cell name.  For example, if
    # a cell with the name :title was defined, then the cell would be able
    # to be read and written like so:
    # 
    #   row.title               #=> Accesses the title
    #   row.title "Page Title"  #=> Creates a new cell with "Page Title" as the content
    def define_cell(name)
      method_name = name.gsub('-', '_')
      
      klass = class << self; self; end
      klass.class_eval do
        define_method(method_name) do |*args|
          if args.empty?
            @row.cells[name]
          else
            @row.cell(name, *args)
          end
        end
      end unless klass.method_defined?(method_name)
    end
    
    # Removes the definition for the given cell
    def undef_cell(name)
      method_name = name.gsub('-', '_')
      
      klass = class << self; self; end
      klass.class_eval do
        remove_method(method_name)
      end
    end
  end
  
  # Represents a single row within a table.  A row can consist of either
  # data cells or header cells.
  class Row < HtmlElement
    # The proxy class used externally to build the actual cells
    attr_reader :builder
    
    # The current cells in this row, in the order in which they will be built
    attr_reader :cells
    
    # The parent element for this row
    attr_reader :parent
    
    delegate :empty?, :to => :cells
    delegate :table, :to => :parent
    
    def initialize(parent) #:nodoc:
      super()
      
      @parent = parent
      @cells = ActiveSupport::OrderedHash.new
      @builder = RowBuilder.new(self)
    end
    
    # Creates a new cell with the given name and generates shortcut
    # accessors for the method.
    def cell(name, *args)
      name = name.to_s if name
      
      options = args.last.is_a?(Hash) ? args.pop : {}
      options[:namespace] = table.object_name
      args << options
      
      cell = Cell.new(name, *args)
      cells[name] = cell
      builder.define_cell(name) if name
      
      cell
    end
    
    # The names of all cells in this row
    def cell_names
      cells.keys
    end
    
    # Clears all of the current cells from the row
    def clear
      # Remove all of the shortcut methods
      cell_names.each {|name| builder.undef_cell(name)}
      cells.clear
    end
    
    private
      def tag_name
        'tr'
      end
      
      def content
        cells.values.map(&:html).join
      end
  end
end
