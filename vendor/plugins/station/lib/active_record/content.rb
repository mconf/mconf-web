module ActiveRecord #:nodoc:
  # A Content is a Resource that needs a Container to exist. Examples of contents
  # are project's tasks or album's images.
  #
  # Include this functionality in your models using ActsAsMethods#acts_as_content
  #
  # == Named Scope
  # You can use the named_scope +in(container)+ to get all contents in some Container.
  #   Content.in(some_container) #=> Array of contents in the container
  #
  # This named scope is used in StationResources controller, in index and show methods.
  # 
  # == Resource Controllers
  # StationResources provides with some facilities when managing resources that
  # are contents also.
  #
  # === index
  # Content resource lists are filtered if a Container is provided in the path
  #
  #  /projects/1/tasks #=> each task in @tasks is in project-1
  #
  # === show
  # Content resource is searched within the container named scope if a Container 
  # is provided in the path
  #
  #  /projects/1/tasks/1 #=> task-1 must belong to project-1
  #
  # === create
  # Automatically set up container relation
  #  
  #  /projects/1/tasks #=> when posting to this path, the new task is created inside projects-1
  #
  # == Authorization
  # The Content incorporates an authorization block that delegates permissions to its Container.
  # 
  # This authorization block ask only single permissions, i.e. a Permission which objective is nil.
  #
  #   class Task
  #     belongs_to :project
  #     acts_as_content :reflection => :project
  #   end
  #
  #   task.authorize?(:update) #=> will ask task.project.authorize?([ :update, :content ]) ||
  #                            #            task.project.authorize?([ :update, :task ])
  #   
  #
  module Content
    class << self
      def included(base) # :nodoc:
        # Fake named_scope to ActiveRecord instances that aren't Contents
        base.named_scope :in, lambda { |container| {} }
        base.class_eval do
          class << self
            __station_deprecate_method__(:in_container, :in)
          end
        end
        base.extend ActsAsMethods
      end

      delegate :all, :paginate, :to => ActiveRecord::Content::Inquirer
    end

    module ActsAsMethods
      # Provides an ActiveRecord model with Content capabilities
      #
      # == Options
      # <tt>reflection</tt>:: Name of the (usually <tt>belongs_to</tt>) association that relates this model with its Container. Defaults to <tt>:container</tt>
      # <tt>authorization</tt>:: Add Authorization block to delegate authorization request to reflection
      def acts_as_content(options = {})
        ActiveRecord::Content.register_class(self)

        options[:reflection]  ||= :container
        options[:authorization] = true if options[:authorization].nil?

        cattr_reader :content_options
        class_variable_set "@@content_options", options

        if options[:reflection] != :container
          alias_attribute :container, options[:reflection]
          attr_protected options[:reflection]
          attr_protected reflections[options[:reflection]].primary_key_name
          if reflections[options[:reflection]].options[:polymorphic]
            attr_protected reflections[options[:reflection]].options[:foreign_type]
          end
        end
        attr_protected :container, :container_id, :container_type

        named_scope :in, lambda { |container|
          { :conditions => container_conditions(container) }
        }

        acts_as_sortable

        if options[:authorization]
          authorization_delegate :container, :as => :content
          authorization_delegate :container
        end

        extend  ClassMethods
        include InstanceMethods
      end
    end

    module ClassMethods
      # The ActiveRecord reflection that represents the Container for this model
      def container_reflection
        reflections[content_options[:reflection]]
      end

      def container_conditions(container)
        case container
        when NilClass
          ""
        when Array
          c = container.map{ |c| container_conditions(c) }.join(" OR ")
          "(#{ c })"
        else
          if container.class.acts_as?(:container)
            c = "#{ table_name }.#{ container_reflection.primary_key_name } = '#{ container.id }'"
            if container_reflection.options[:polymorphic]
              c << " AND #{ table_name }.#{ container_reflection.options[:foreign_type] } = '#{ container.class.base_class }'"
            end
            "(#{ c })"
          else
            ""
          end
        end
      end

      # ActiveRecord Scope used by ActiveRecord::Content::Inquirer
      #
      # By default uses roots.in(container) find scope
      #
      # Options:
      # container:: The container passed to in(container) named_scope
      def content_inquirer_scope(options = {})
        inquirer_scope = roots.in(options[:container]).scope(:find)
      end

      # Construct SQL query used by ActiveRecord::Content::Inquirer
      #
      # params is a hash of parameters passed to ActiveRecord, like in a regular query
      #
      # scope_options will be passed to content_inquirer_scope
      #
      def content_inquirer_query(params = {}, scope_options = {})
        inquirer_scope = content_inquirer_scope(scope_options)

        # Clean scope parameters like :order
        inquirer_scope.delete(:order)

        with_scope(:find => inquirer_scope) do
          construct_finder_sql(params)
        end
      end
    end

    module InstanceMethods
      # Has this Content been posted in this Container?
      def in?(container)
        container == self.container
      end
    end
  end
end


