# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
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

      if user && user.is_a?(User) && !user.timezone.blank?
        zone = user.timezone
      elsif current_site && !current_site.timezone.blank?
        zone = current_site.timezone
      else
        # if everything fails defaults to UTC
        zone = "UTC"
      end
      ActiveSupport::TimeZone[zone]
    end

    # Returns the offset of a user's time zone as a string.
    # Ex: "-07:00"
    def self.user_time_zone_offset(user=nil)
      self.user_time_zone(user).formatted_offset
    end

    # Returns whether a user has a time zone set or not.
    def self.user_has_time_zone?(user=nil)
      user and user.is_a?(User) and not user.timezone.blank?
    end

    # Used to parse a date obtained from a form together with a timezone
    # and return it in UTC respecting daylight savings time
    def self.parse_in_timezone date, time, time_zone, date_format=nil
      # strptime doesnt do time zones correctly because of daylight savings time
      # so we parse it without and use ActiveSupport::TimeZone to do the time zone
      if date_format.present?
        d = DateTime.strptime(date, date_format)
      else
        d = DateTime.parse(date)
      end
      t = DateTime.parse(time)

      d = d.change hour: t.hour, min: t.min

      ActiveSupport::TimeZone[time_zone].parse(d.strftime('%c'))
    end
  end

  class DSTTimezone

    def initialize(tz)
      if tz.is_a?(String)
        @tz = ActiveSupport::TimeZone.new(tz)
      else
        @tz = tz
      end
    end

    def self.all
      ActiveSupport::TimeZone.all.map do |tz|
        DSTTimezone.new(tz)
      end
    end

    def dst_string
      if dst?
        "(GMT#{dst_hours}*) #{name}"
      else
        "(GMT#{dst_hours}) #{name}"
      end
    end

    def dst_hours
      ActiveSupport::TimeZone.seconds_to_utc_offset(@tz.now.utc_offset)
    end

    def name
      @tz.name
    end

    def tzinfo
      @tz.tzinfo
    end

    def dst?
      Time.now.in_time_zone(@tz).dst?
    end
  end
end
