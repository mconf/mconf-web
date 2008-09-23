    atom_feed({'xmlns:gd' => 'http://schemas.google.com/g/2005', 
    'xmlns:sir' => 'http://sir.dit.upm.es/schema'}) do |feed|
      feed.title("Spaces")
      feed.updated((@spaces.first.updated_at  unless @spaces.first==nil))

      for space in @spaces
        feed.entry(space) do |entry|
          entry.title(space.name)
          entry.summary(space.description, :type => 'html')
          entry.tag!('gd:deleted', space.deleted)
          entry.tag!('sir:parent_id', space.parent_id)
       
          if space.public == true
            entry.tag!('gd:visibility', "public")
          else 
            entry.tag!('gd:visibility', "private")
          end

          entry.author do |author|
            author.name("SIR")
          end
        end
      end
    end
