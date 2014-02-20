module Mconf
  module Modules
    # Indicates whether a module `mod` is enabled or not.
    # Used usually to check if a given set of resources should be loaded or not.
    def mod_enabled?(mod)
      configatron.modules[mod].enabled
    end

    # def self.mod_enabled?(mod)
    #   configatron.modules[mod].enabled
    # end
  end
end
