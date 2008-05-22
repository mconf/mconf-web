# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
 
 
   def base_language_only
    yield if Locale.base?
  end

  def not_base_language
    yield unless Locale.base?
  end
  #this method is to create the tag_cloud in our views
  
def build_tag_cloud(tag_cloud, style_list)
max, min = 0, 0
tag_cloud.each do |tag|
max = tag.popularity.to_i if tag.popularity.to_i > max
min = tag.popularity.to_i if tag.popularity.to_i < min
end

divisor = ((max - min) / style_list.size) + 1

tag_cloud.each do |tag|
yield tag.name, style_list[(tag.popularity.to_i - min) / divisor]
end
end

def tag_item_url(name)
  "/search_events?query=#{name}&commit=Search"
end
#method that replace a true (1 in the database) or a false (0 in the database)
  #with an image 
  def replace_image(atr)
     if atr == true
  image_tag("/images/ok.jpg",:border=>0)
 else 
 image_tag("/images/cancel.gif",:border=>0)
end
end



def javascript(file_name, space_id, role_id=nil)
  content_for(:head) {  "<script src=\"/js/src/rico.js\" type=\"text/javascript\"></script>" }
  if role_id!=nil
    content_for(:head) {  "<script src=\"/cjavascripts/"+file_name+".js/"+space_id+"/"+role_id+"\" type=\"text/javascript\"></script>" }
    return
  else
    debugger
    content_for(:head) {  "<script src=\"/cjavascripts/"+file_name+".js/"+space_id+"\" type=\"text/javascript\"></script>" }  
    return
  end
end


end
