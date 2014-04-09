module Mconf
  class EventInvitation < Mconf::Invitation
    attr_accessor :event

    def to_ical
      event.to_ics.to_ical
    end
  end
end