    atom_entry(@space, {'xmlns:gd' => 'http://schemas.google.com/g/2005',
        'xmlns:sir' => 'http://sir.dit.upm.es/schema'}) do |entry|

          entry.title(@space.name)
          entry.summary(@space.description, :type => 'html')
          entry.tag!('gd:deleted', @space.deleted)
          entry.tag!('sir:parent_id', @space.parent_id)
          if @space.public == true
            entry.tag!('gd:visibility', "public")
          else 
            entry.tag!('gd:visibility', "private")
          end
          

          entry.author do |author|
            author.name("SIR")
          end

      
    end
