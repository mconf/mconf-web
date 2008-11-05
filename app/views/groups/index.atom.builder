    atom_feed({'xmlns:gd' => 'http://schemas.google.com/g/2005', 
    'xmlns:sir' => 'http://sir.dit.upm.es/schema'}) do |feed|
      feed.title("Groups")
      feed.updated((@groups.first.updated_at unless @groups.first==nil))

      for group in @groups
        feed.entry(group, :url => space_group_path(@space, group)) do |entry|
          entry.title(group.name)
        
          for user in group.users
            entry.tag!('sir:entryLink', :login => user.login, 
            :href => "http://sir.dit.upm.es/spaces/#{@space.name}/users/#{user.id}")
          end
      
          
          entry.author do |author|
            author.name("SIR")
          end
        end
      end
    end
