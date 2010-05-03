atom_feed('xmlns:gd' => 'http://schemas.google.com/g/2005',
          :root_url => polymorphic_url([ space, Event.new ])) do |feed|
  feed.title("Events - #{ space.name }")
  feed.updated(@events.any? && @events.first.updated_at || Time.now)
  feed.logo(logo_image_url(space, :size => 'h64'))

  @events.each do |event|
    feed.entry(event, :url => space_event_path(space, event)) do |entry|
      entry.title(sanitize event.name)
      entry.summary(sanitize event.description)
      
      if event.start_date   
        entry.tag!('gd:when', :startTime => event.start_date.to_datetime, :endTime => event.end_date.to_datetime)
      end
      
      entry.author do |author|
        author.name(sanitize(event.author.name))
      end
    end
  end
end
