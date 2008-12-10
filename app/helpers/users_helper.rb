module UsersHelper
  def replace_image(atr)
     if atr == true
        image_tag("/images/yes.png",:border=>0)
     else 
        image_tag("/images/delete22.png",:border=>0)
     end
  end

end