    atom_entry(@group, {'xmlns:gd' => 'http://schemas.google.com/g/2005', 
    'xmlns:sir' => 'http://sir.dit.upm.es/schema',
    :url => formatted_space_event_path(@space, @group, :atom), :root_url => space_event_path(@space, @group)}) do |entry|

          entry.title(@group.name)
        
          for user in @group.users
            entry.tag!('sir:entryLink', :login => user.login, 
            :href => "http://sir.dit.upm.es/spaces/#{@space.name}/users/#{user.id}")
          end
      
          
          entry.author do |author|
            author.name("SIR")
          end
        end
    



