module ActiveRecord #:nodoc:
  # Container(s) are models receiving Content(s) posted by Agent(s)
  module Sortable
    def self.included(base) #:nodoc:
      # Fake named_scope for ActiveRecord that aren't Sortables
      base.named_scope :column_sort, lambda { |order, direction| {} }
      base.extend ClassMethods
    end

    module ClassMethods
      # Provides an ActiveRecord model with Sort capabilities
      #
      # Example:
      #   acts_as_sortable :columns => [ :name,
      #                                  :description,
      #                                  { :name    => "Container",
      #                                    :content => :container,
      #                                    :sortable => false } ]
      #
      # Options:
      # default_order:: Sort by this order by default.
      # default_direction:: Sort by this direction default
      # columns:: Array of columns that will be displayed. 
      # Columns can be defined in two ways: 
      # Hash:: Describe each column attributes. These are:
      # * name: Title of the column
      # * content: The content that will be displayed for each object of the list. See ActiveRecord::Sortable::Column#data
      # * order: The +ORDER+ fragment in the SQL code
      # * sortable: The list can be ordered by this column. Defaults to <tt>true</tt>
      # Symbol:: Takes defaults for each column attribute
      def acts_as_sortable(options = {})
        ActiveRecord::Sortable.register_class(self)

        options[:columns] ||= self.table_exists? ? 
          self.columns.map{ |c| c.name.to_sym } :
          Array.new

        cattr_reader :sortable_options
        class_variable_set "@@sortable_options", options

        named_scope :column_sort, lambda { |order, direction|
          { :order => sanitize_order_and_direction(order, direction) }
        }
      end

      # Return all ActiveRecord::Sortable::Column for this Model
      def sortable_columns
        @sortable_columns ||= sortable_options[:columns].map{ |c| ActiveRecord::Sortable::Column.new(c) }
      end

      # Sanitize user send params
      def sanitize_order_and_direction(order, direction)
        default_order = sortable_options[:default_order] ||
          column_names.include?("updated_at") && "#{ table_name }.updated_at" || 
          [ table_name, columns.first.name ].join('.')

        default_direction = sortable_options[:default_direction] ||
          column_names.include?("updated_at") && "ASC" || 
          "DESC"

        # Remove all but letters and dots
        order = order ? order.gsub(/[^\w\.]/, '') : default_order

        direction = direction && %w{ ASC DESC }.include?(direction.upcase) ?
          direction :
          default_direction

        "#{ order } #{ direction }"
      end
    end

    # This class models columns that are shown in sortable_list
    class Column
      attr_reader :content, :name, :order, :sortable, :render
      alias sortable? sortable

      def initialize(column) #:nodoc:
        case column
        when Symbol
          @content = column
          @name = column
          @order = column.to_s
          @sortable = true
        when Hash
          @content = column[:content]
          @name = column[:name] || column[:content]
          @order = column[:order] || column[:content] && column[:content].is_a?(Symbol) && column[:content].to_s || ""
          @sortable = column[:sortable] || true
          @render = column[:render]
        end
      end

      def name
        case @name
        when Symbol
          I18n.t("#{ @name }.one")
        else
          @name
        end
      end

      # Get data for this object based in <tt>:content</tt> parameter. 
      # There are two types of <tt>:content</tt> parameter:
      # Symbol:: represents a method of the object, like <tt>object.name</tt>
      # Proc:: more complicate data. Example:
      #   :content => proc{ |helper, object|
      #     helper.link_to(object.container.name, helper.polymorhic_path(object.container))
      #   }
      #
      def data(helper, object)
        if render
          return helper.render(:partial => render, :object => object)
        end

        case content
        when Symbol
          o = object.send content
          if o.is_a?(::ActiveRecord::Base)
            begin
              helper.link_to(helper.sanitize(o.name), helper.polymorphic_path(o))
            rescue 
              helper.sanitize(o.name)
            end
          else
            helper.sanitize(o.to_s)
          end
        when Proc
          content.call(helper, object)
        end
      end
    end
  end
end
