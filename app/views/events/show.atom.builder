atom_entry(@event, {'xmlns:gd' => 'http://schemas.google.com/g/2005', 
    'xmlns:sir' => 'http://sir.dit.upm.es/schema', 
  :url => formatted_space_event_path(@space, @event, :atom), :root_url => space_event_path(@space, @event)}) do |entry|
  entry.title(@event.name)
  entry.summary(@event.description)
  entry.updated((@event.entry.updated_at.to_datetime))
  
  index = 0
  @event.event_datetimes.each do |d|         
    entry.tag!('gd:when', :startTime => d.start_date.to_datetime, :endTime => d.end_date.to_datetime, :valueString => index.to_s)
    index+1
  end   
  
  entry.author do |author|
    author.name("SIR")
  end
  
end
