# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

module Mconf

  # Utility class to deal with timezones.
  class Timezone

    # Returns the time zone of a user. Will first try to get the user's time zone,
    # then the website's time zone and then a default time zone if everything else fails.
    # Returns an object of the type ActiveSupport::TimeZone
    def self.user_time_zone(user=nil)
      current_site = Site.current

      if user and user.is_a?(User) and not user.timezone.blank?
        zone = user.timezone
      elsif current_site and not current_site.timezone.blank?
        zone = current_site.timezone
      else
        # if everything fails defaults to UTC
        zone = "UTC"
      end
      ActiveSupport::TimeZone[zone]
    end

  end
end
