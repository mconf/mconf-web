# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

module Mconf
  class DialNumber
    def self.generate(pattern=nil, opt={})
      sym = opt[:symbol] || 'x'

      # For each 'x' (sym) in the pattern text
      # substitute it for a random integer in [0-9]
      result = pattern

      if pattern.present?
        pattern.count(sym).times do
          result.sub!(sym, Kernel.rand(10).to_s)
        end
      end

      result
    end
  end
end
