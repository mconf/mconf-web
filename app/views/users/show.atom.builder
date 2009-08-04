    atom_entry(@user, {'xmlns:gd' => 'http://schemas.google.com/g/2005', 
    'xmlns:sir' => 'http://sir.dit.upm.es/schema'}) do |entry|

          entry.title(@user.login)
          entry.tag!('gd:email', :address => @user.email, :primary => true)
 
          entry.author do |author|
            author.name(t('feed.author'))
          end

    end
