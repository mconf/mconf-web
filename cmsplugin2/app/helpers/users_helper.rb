module UsersHelper
  def replace_image(atr)
     if atr == true
  image_tag("/images/ok.jpg",:border=>0)
 else 
 image_tag("/images/cancel.gif",:border=>0)
end
end
end