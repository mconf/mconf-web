# Mime types for calendars
# Both .ical and .ics are used, but it seems .ics is more readily recognized
# by software manipulating calendars so we're defining a renderer for it.
ActionController::Renderers.add :ics do |resource, options|
  filename = resource.try(:name) || 'events.ics'
  content = resource.respond_to?(:to_ical) ? resource.to_ical : resource
  send_data content, type: Mime::ICS, disposition: "attachment; filename=#{filename}"
end
