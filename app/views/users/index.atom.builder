    atom_feed({'xmlns:gd' => 'http://schemas.google.com/g/2005', 
    'xmlns:sir' => 'http://sir.dit.upm.es/schema'}) do |feed|
      feed.title("Users")
      feed.updated((@users.first.updated_at unless @users.first==nil))

      for user in @users
        feed.entry(user) do |entry|
          entry.title(user.login)
          entry.tag!('gd:email', :address => user.email, :primary => true)
          entry.tag!('gd:email', :address => user.email2)
          entry.tag!('gd:email', :address => user.email3)
       
          

          entry.author do |author|
            author.name("SIR")
          end
        end
      end
    end
