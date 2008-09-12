    atom_feed do |feed|
      feed.title("Spaces")
      feed.updated((@spaces.first.created_at))

      for space in @spaces
        feed.entry(space) do |entry|
          entry.title(space.name)
          entry.id(space.id)
          entry.name(space.name)
          entry.description(space.description)
          entry.created_at(space.created_at)
          entry.deleted(space.deleted)
          entry.parent_id(space.parent_id)
          entry.public(space.public)
          entry.updated_at(space.updated_at)
          

          entry.author do |author|
            author.name("SIR")
          end
        end
      end
    end
