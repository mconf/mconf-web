# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

module Mconf
  class Invitation

    attr_accessor :name
    attr_accessor :description
    attr_accessor :starts_on
    attr_accessor :ends_on
    attr_accessor :organizer
    attr_accessor :url

    def to_ical
      event = Icalendar::Event.new
      # We send the dates always in UTC to make it easier. The 'Z' in the ends denotes
      # that it's in UTC.
      event.dtstart = @starts_on.in_time_zone('UTC').strftime("%Y%m%dT%H%M%SZ")
      event.dtend = @ends_on.in_time_zone('UTC').strftime("%Y%m%dT%H%M%SZ")
      event.organizer = @organizer
      event.klass = "PUBLIC"
      event.uid = @url
      event.url = @url
      event.location = @url
      event.description = @description
      event.summary = @name

      cal = Icalendar::Calendar.new
      cal.add_event(event)
      cal.to_ical
    end

  end
end
