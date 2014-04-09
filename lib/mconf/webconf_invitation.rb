module Mconf
  class WebconfInvitation < Mconf::Invitation
    attr_accessor :starts_on
    attr_accessor :ends_on
    attr_accessor :room

    def to_ical
      event = Icalendar::Event.new
      # We send the dates always in UTC to make it easier. The 'Z' in the ends denotes
      # that it's in UTC.
      event.dtstart = @starts_on.in_time_zone('UTC').strftime("%Y%m%dT%H%M%SZ")
      event.dtend = @ends_on.in_time_zone('UTC').strftime("%Y%m%dT%H%M%SZ")
      event.organizer = @from.email
      event.klass = "PUBLIC"
      event.uid = @url
      event.url = @url
      event.location = @url
      event.description = @description
      event.summary = @title

      cal = Icalendar::Calendar.new
      cal.add_event(event)
      cal.to_ical
    end
  end
end