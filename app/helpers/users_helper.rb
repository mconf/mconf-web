module UsersHelper
  def replace_image(atr)
     if atr == true
        image_tag("/images/ok.jpg",:border=>0)
     else 
        image_tag("/images/cancel.gif",:border=>0)
     end
  end

  def create_table_users
   tabla = "<table  WIDTH=95% BORDER=0 CELLSPACING=0 CELLPADDING=0 align='center'> <tr><td align='center'>Name (Login)</td><td align='center'>Lastname</td>"
  if logged_in? 
   tabla += "<td align='center'>Email</td>" 
  end
  tabla += "<td align='center'>Organization</td><td align='center'>Role</td><td align='center'>Tags</td></tr>"
end

  def generate_user_table
    name = "<div class='name'> Login / (name,lastname) </div>"
    organization = "<div class='organization'> Organization </div>"
    interests = "<div class='interests'> Interests </div>"
    members = "<div class='members'> Member of </div> "
    line = name + organization + interests + members + "<br/> <br/>"
    return line
    
  end
  def show_list_user(user)
    
    div_user = "<div class= 'name'>" + name_format( user.login  + (" / "+user.profile.name + "  " + user.profile.lastname if user.profile).to_s,25,"") + "</div>"
    div_organization = "<div class= 'organization'>" + (name_format(user.organization ,17,"") if user.profile).to_s + "</div>"
    div_interests = "<div class= 'interests'>" + (name_format(user.tag_list ,23,"")).to_s + "</div>"
    div_members = "<div class= 'members'>" + (name_format(member_spaces(user) ,27,"")).to_s + "</div>"
    line = div_user + div_organization + div_interests + div_members
    return line
  end
  
  def member_spaces(user)

  spaces = ""
    if user.stages.length== 0
      return "none"
  else
    user.stages.each do |space|
      spaces += space.name + " ,"
    end
  end
   return spaces[0,spaces.length-1]
  end

end