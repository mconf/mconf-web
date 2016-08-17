# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# TODO: #1271 This class is only needed to support users that were generated
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
