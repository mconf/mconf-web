atom_entry(@event, {'xmlns:gd' => 'http://schemas.google.com/g/2005', 
:url => formatted_space_event_path(@space, @event, :atom), :root_url => space_event_path(@space, @event)}) do |entry|
  entry.title(@event.name)
  entry.summary(@event.description)
  entry.updated((@event.content_entries.first.updated_at.to_datetime))
  
  
  entry.author do |author|
    author.name("SIR")
  end
  
end
