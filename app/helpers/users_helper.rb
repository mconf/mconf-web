module UsersHelper
  def replace_image(atr)
     if atr == true
        image_tag("/images/yes.png",:border=>0)
     else 
        image_tag("/images/delete22.png",:border=>0)
     end
  end

  #method to know if an user is the only admin in the space
  def is_last_admin(space, performance)
    #we check first if the performance is "Admin"
    if performance.role_id != Role.find_by_name("Admin").id
      return false
    end
    #And now if it is the last one
    if Performance.find_all_by_stage_id_and_stage_type_and_role_id(space.id, "Space", Role.find_by_name("Admin")).count < 2
      return true
    end
  end
  
end