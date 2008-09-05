xml.content(:type => "xhtml") do
  xml.div(:xmlns => "http://www.w3.org/1999/xhtml") do
    @event = entry.event
    xml << render :partial => 'events/show_summary'
  end
end
