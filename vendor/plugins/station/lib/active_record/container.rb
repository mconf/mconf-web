module ActiveRecord #:nodoc:
  # == acts_as_container
  # A Container is a model that has many other models that depend on it. Example of
  # containers are a project with tasks, a forum with posts or an album with photos.
  # The formal relationship of a container with its contents is called {Composition}[http://en.wikipedia.org/wiki/Class_diagram#Composition].
  #
  # You recognize that <b>foo is a container</b> when it has a <tt>has_many :bar</tt>
  # declaration, <b>bar</b> needs <b>foo</b> to be created and you manage routes like
  # <tt>/foos/1/bars</tt>
  #
  # Using ActsAsMethods#acts_as_container in your model provides you with some
  # features.
  #   class Foo
  #     acts_as_container :contents => :bar
  #   end
  #
  # == Facilities in your Controller
  # Station supported Controllers provide some facilities when you declare 
  # some models as containers.
  #
  # There are some methods available for finding containers in paths. See 
  # ActionController::Station#path_container and 
  # ActionController::Station#current_container 
  #
  # == Content::Inquirer
  # A typical usage of a Container is obtaining a list of all its contents,
  # whatever their classes are, and manage pagination, conditions and other 
  # ActiveRecord goodies.
  #
  # Station provides you with the Content::Inquirer, a fake ActiveRecord class
  # that supports multiple quering and instanciating multiple type of contents
  # at the same time.
  #
  # == Sources
  # You can import feeds into your container, mapping each feed entry to
  # a Content instance. See Source.
  #
  module Container
    class << self
      def included(base) #:nodoc:
        base.extend ActsAsMethods
      end
    end

    module ActsAsMethods
      # Provides an ActiveRecord model with Container capabilities
      #
      # Options:
      # <tt>contents</tt>:: an Array of Contents that can be posted to this Container. Ex: [ :articles, :images ]. Defaults to all available Content models.
      # <tt>sources</tt>:: The container has remote sources. It will import Atom/RSS feeds as contents. See Source. Defaults to false
      def acts_as_container(options = {})
        ActiveRecord::Container.register_class(self)

        cattr_reader :container_options
        class_variable_set "@@container_options", options

        if options[:sources]
          has_many :sources, :as => :container,
                             :dependent => :destroy
        end

        extend  ClassMethods
        include InstanceMethods
      end
    end

    module ClassMethods
      # Array of symbols representing the Contents that this Container supports
      def contents
        container_options[:contents] || ActiveRecord::Content.symbols
      end
    end


    # Instance methods can be redefined in each Model for custom features
    module InstanceMethods #:nodoc:
      # Array of contents of this container instance.
      #
      # Uses ActiveRecord::Content::Inquirer for building the query in 
      # several tables.
      def contents(options = {})
        container_options[:containers] = Array(self)

        ActiveRecord::Content::Inquirer.all(options, container_options)
      end

      # A list of all the nested containers of this Container, including self,
      # sorted by closeness
      #
      # Station currently supports only one container per content. This means
      # that container relations make up a directed tree. This method returns
      # the branch of parent containers until the root.
      def container_and_ancestors
        ca = respond_to?(:container) && container.try(:container_and_ancestors) || nil

        (Array(self) + Array(ca)).compact
      end
    end
  end
end
