
        atom_entry(@space) do |entry|
          entry.title(@space.name)
          entry.summary(@space.description, :type => 'html')
          entry.tag!('gd:deleted', @space.deleted)
          entry.tag!('gd:where', @space.parent_id)
          entry.tag!('gd:visibility', "public")
          

          entry.author do |author|
            author.name("SIR")
          end
        end

