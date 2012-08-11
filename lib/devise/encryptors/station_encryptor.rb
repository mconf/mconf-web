# TODO: This class is only needed to support users that were generated
#       with station and therefore have a salt. This should be replaced
#       in the future by devise's standard encryption methods.'
#       We could use https://github.com/plataformatec/devise/wiki/How-To:-Migration-legacy-database

require 'digest/sha1'

module Devise
  module Encryptable
    module Encryptors
      class StationEncryptor < Base
        def self.digest(password, stretches, salt, pepper)
          Digest::SHA1.hexdigest("--#{salt}--#{password}--")
        end
      end
    end
  end
end
