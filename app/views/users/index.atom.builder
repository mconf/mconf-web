    atom_feed({'xmlns:gd' => 'http://schemas.google.com/g/2005', 
    'xmlns:sir' => 'http://sir.dit.upm.es/schema'}) do |feed|
      feed.title(t('user.feed.title'))
      feed.updated((@users.first.updated_at unless @users.first==nil))

      for user in @users
        feed.entry(user) do |entry|
          entry.title(user.username)
          entry.tag!('gd:email', :address => user.email, :primary => true)
       
          

          entry.author do |author|
            author.name(t('user.feed.author'))
          end
        end
      end
    end
