    atom_feed({'xmlns:gd' => 'http://schemas.google.com/g/2005'}) do |feed|
      feed.title("Events")
      feed.updated((@events.first.content_entries.first.updated_at unless @events.first==nil))

      for event in @events
        feed.entry(event, :url => space_event_path(@space, event)) do |entry|
          entry.title(event.name)
          entry.summary(event.description)
          entry.updated((event.content_entries.first.updated_at.to_datetime))
          

          entry.author do |author|
            author.name("SIR")
          end
        end
      end
    end
