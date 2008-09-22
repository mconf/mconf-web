    atom_feed({'xmlns:gd' => 'http://schemas.google.com/g/2005'}) do |feed|
      feed.title("Spaces")
      feed.updated((@spaces.first.updated_at  unless @spaces.first==nil))

      for space in @spaces
        feed.entry(space) do |entry|
          entry.title(space.name)
          entry.summary(space.description, :type => 'html')
          entry.tag!('gd:deleted', space.deleted)
          entry.tag!('gd:where', space.parent_id)
          entry.tag!('gd:visibility', "public")
          

          entry.author do |author|
            author.name("SIR")
          end
        end
      end
    end
