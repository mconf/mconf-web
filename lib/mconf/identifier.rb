# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

module Mconf
  class Identifier

    # Returns an unique identifier for Mconf, typically used for usernames,
    # space identifiers or room identifiers.
    # Uses `base_value` to generate the identifier (a parameterized `base_value`)
    # and makes sure it is unique in the application.
    def self.unique_mconf_id(base_value)
      new_value = base_value
      new_value = new_value.parameterize unless base_value.nil?
      base = new_value

      # blank values will generate empty identifiers, so return nil to cause
      # an error in the caller
      if new_value.blank?
        nil
      else
        num = 2

        loop do
          # have to consider both users and spaces, including disabled ones
          users = User.with_disabled.where(slug: new_value).count
          spaces = Space.with_disabled.where(slug: new_value).count
          rooms = BigbluebuttonRoom.where(slug: new_value).count

          # blacklisted words
          file = File.join(::Rails.root, "config", "reserved_words.yml")
          words = YAML.load_file(file)['words']

          break if users == 0 && spaces == 0 && rooms == 0 && !words.include?(new_value)

          new_value = "#{base}-#{num}"
          num += 1
        end

        new_value
      end
    end
  end
end
