module Mconf
  module Modules

    # Indicates whether a module `mod` is enabled or not.
    # Used usually to check if a given set of resources should be loaded or not.
    def mod_enabled?(mod)
      Mconf::Modules.mod_enabled?(mod)
    end

    def self.mod_enabled?(mod)
      case mod
      when 'events'
        mod_loaded?(mod) &&
          defined?(Site) && Site.table_exists? && Site.current &&
          Site.current.respond_to?(:events_enabled) &&
          Site.current.events_enabled?
      else
        false
      end
    end

    # Indicates whether a module `mod` was loaded or not.
    # Used usually to check if routes should be added or not.
    def mod_loaded?(mod)
      Mconf::Modules.mod_loaded?(mod)
    end

    def self.mod_loaded?(mod)
      configatron.modules[mod].loaded
    end

  end
end
