# Mime types for calendars
# Both .ical and .ics are used, but it seems .ics is more readily recognized
# by software manipulating calendars so we're defining a renderer for it.
ActionController::Renderers.add :ics do |ics, options|
  self.content_type ||= Mime::Ics
  self.response_body  = ics.respond_to?(:to_ical) ? ics.to_ical : ics
end