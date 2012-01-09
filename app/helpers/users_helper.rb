module UsersHelper

  def replace_image(atr)
     if atr == true
        image_tag("/assets/yes.png",:border=>0)
     else
        image_tag("/assets/delete22.png",:border=>0)
     end
  end

end
