begin
  require 'casclient'
rescue MissingSourceFile
  raise "Station: You need 'rubycas-client' gem for CAS authentication support"
end

module ActiveRecord #:nodoc:
  module Agent
    # Agent Authentication Methods
    module Authentication
      # Central Authentication Service (CAS) authentication support
      #
      # Options:
      # * cas_filter: Options to pass to the CAS Filter
      module CAS
        class << self
          def included(base) #:nodoc:
            base.extend ClassMethods
          end
        end

        module ClassMethods
          # Find first Agent of this class with this cas_id
          def authenticate_with_cas(cas_id)
            find_by_login(cas_id)
          end
        end
      end
      Cas = CAS
    end
  end
end
