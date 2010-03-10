module ActiveRecord #:nodoc:
  # Provides some functionality to modules that enhance ActiveRecord 
  # with acts_as_something
  module ActsAs #:nodoc:
    # All ActiveRecord addons
    Features = [ :resource,
                 :container,
                 :agent,
                 :content,
                 :stage,
                 :taggable,
                 :logoable,
                 :sortable ]

    class << self
      def extended(base)
        Features.each do |feature|
          require_dependency "active_record/#{ feature }"
          feature_const = "ActiveRecord::#{ feature.to_s.classify }".constantize
          feature_const.send :include, Feature
          base.send :include, feature_const
        end
      end
    end

    def acts_as?(feature)
      return false unless Features.include?(feature.to_sym)

      respond_to? "#{ feature }_options"
    end

    module Feature #:nodoc:
      class << self
        def included(base) #:nodoc:
          base.instance_variable_set "@symbols", Array.new
          base.extend ClassMethods
        end
      end

      module ClassMethods #:nodoc:
        def symbols
          @symbols
        end

        def register_class(klass)
          @symbols |= Array(klass.to_s.tableize.to_sym)
        end

        def classes
          @symbols.map { |s|
            begin
              s.to_class
            rescue
              puts "Station Warning: Couldn't load class #{ s.to_s.classify }"
              nil
            end
          }.compact
        end
      end
    end
  end
end
