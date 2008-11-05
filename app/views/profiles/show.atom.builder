    atom_entry(@profile, {'xmlns:gd' => 'http://schemas.google.com/g/2005', 
    'xmlns:sir' => 'http://sir.dit.upm.es/schema', 
    :url => formatted_user_profile_path(@user, :atom), :root_url => user_profile_path(@user)}) do |entry|

          entry.title(@profile.name)
          entry.tag!('sir:lastname', @profile.lastname)
          entry.tag!('sir:address', @profile.address)
          entry.tag!('sir:city', @profile.city)
          entry.tag!('sir:zipcode', @profile.zipcode)
          entry.tag!('sir:province', @profile.province)
          entry.tag!('sir:country', @profile.country)
          entry.tag!('gd:phoneNumber', {:rel => "http://schemas.google.com/g/2005#home"}, @profile.phone)
          entry.tag!('gd:phoneNumber', {:rel => "http://schemas.google.com/g/2005#fax"}, @profile.fax)
          entry.tag!('gd:phoneNumber', {:rel => "http://schemas.google.com/g/2005#mobile"}, @profile.mobile)
          entry.tag!('gd:organization') do |org|
            org.tag!('gd:orgName', @profile.organization)
          end
          
          entry.author do |author|
            author.name("SIR")
          end
        end
    
