module ActionController
  # Base methods for ActionController
  module Station
    # Inclusion hook to make container_content methods
    # available as ActionView helper methods.
    class << self
      def included(base) #:nodoc:
        base.helper_method :model_class
        base.helper_method :current_site
        base.helper_method :path_container
        base.helper_method :current_container

        class << base
          def model_class
            @model_class ||= controller_name.classify.constantize
          end

          # Set params from AtomPub raw post
          def set_params_from_atom(atom_parser, options)
            parser = case atom_parser
                     when Proc
                       atom_parser
                     when Class
                       atom_parser.method(:atom_parser).to_proc
                     when Symbol
                       atom_parser.to_class.method(:atom_parser).to_proc
                     else
                       raise "Invalid AtomParser: #{ atom_parser.inspect }"
                     end

            before_filter options do |controller|
              if controller.request.format == Mime::ATOM
                controller.params = controller.params.merge(parser.call(controller.request.raw_post))
              end
            end
          end
        end
      end
    end

    # Returns the Model Class related to this Controller 
    #
    # e.g. Attachment for AttachmentsController
    #
    # Useful for Controller inheritance
    def model_class
      self.class.model_class
    end

    # Obtains a given ActiveRecord instance from parameters. 
    #
    # Returns the first of records_from_path. Same options.
    def record_from_path(options = {})
      records_from_path(options).first
    end

    # Obtains all ActiveRecord record in parameters. 
    #
    # Given this URI:
    #   /projects/1/tasks/2/posts/3
    #
    #   records_from_path #=> [ Project-1, Task-2 ]
    #
    # Options:
    # * acts_as: the ActiveRecord model must acts_as the given symbol.
    #   acts_as => :container
    def records_from_path(options = {})
      acts_as_module = "ActiveRecord::#{ options[:acts_as].to_s.classify }".constantize if options[:acts_as]

      candidates = params.keys.select{ |k| k[-3..-1] == '_id' }

      candidates.map { |candidate_key|
        # Filter keys that correspond to classes
        begin
          candidate_class = candidate_key[0..-4].to_sym.to_class
        rescue NameError
          next
        end

        # acts_as filter
        if options[:acts_as]
          next unless acts_as_module.classes.include?(candidate_class)
        end

        next unless candidate_class.respond_to?(:find)

        # Find record
        begin
          candidate_class.find_with_param(params[candidate_key])
        rescue ::ActiveRecord::RecordNotFound
          next
        end
      }.compact
    end

    # An instance modeling site configuration and stage
    def current_site
      @current_site ||= Site.current
    end

    # Find all Containers in the path, using records_from_path
    #
    # Options:
    # ancestors:: include containers's containers
    # type:: the class of the searched containers
    def path_containers(options = {})
       @path_containers ||= records_from_path(:acts_as => :container)

       candidates = options[:ancestors] ?
         @path_containers.map{ |c| c.container_and_ancestors }.flatten.uniq :
         @path_containers.dup

       filter_type(candidates, options[:type])
    end

    # Find current Container using path from the request
    #
    # Uses path_containers. Same options.
    def path_container(options = {})
      path_containers(options).first
    end

    # Must find a Container
    #
    # Calls path_container to figure out from params. If unsuccesful,
    # raises ActiveRecord::RecordNotFound
    #
    def path_container!(options = {})
      path_container(options) || raise(ActiveRecord::RecordNotFound)
    end

    # Find current Container using path from the request
    #
    # Note that in StationResouces this method is redefined looking also at the resource
    #
    # Options:
    # type:: the class the container should be
    # path_ancestors:: include the ancestors of the resources in the path
    def current_container(options = {})
      options[:ancestors] = options.delete(:path_ancestors)

      path_container(options)
    end

    # Must find a Container
    # 
    # Calls current_container to figure out from params. If unsuccesful,
    # raises ActiveRecord::RecordNotFound
    #
    # Takes the same options as current_container
    # 
    def current_container!(options = {})
      current_container(options) || raise(ActiveRecord::RecordNotFound)
    end

    protected

    # Extract request parameters when posting raw data
    def set_params_from_raw_post(content = controller_name.singularize.to_sym)
      return if request.raw_post.blank? || params[content]

      filename = request.env["HTTP_SLUG"] || controller_name.singularize
      content_type = request.content_type
      
      file = Tempfile.new("media")
      file.write request.raw_post
      (class << file; self; end).class_eval do
        alias local_path path
        define_method(:content_type) { content_type.dup.taint }
        define_method(:original_filename) { filename.dup.taint }
      end

      params[content]                  ||= {}
      params[content][:title]          ||= filename
      params[content][:media]          ||= file
      params[content][:public_read]    ||= true
    end
    
    private

    def filter_type(candidates, type) #:nodoc:
      return candidates.dup unless type

      types = Array(type).map(&:to_sym).map(&:to_class)

      types.inject([]) do |selected, type|
        selected | candidates.select{ |c| c.is_a?(type) }
      end
    end
  end
end
