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


def rounded(options={}, &content)
    options = {:class=>"box"}.merge(options)
    options[:class] = "box " << options[:class] if options[:class]!="box"

    str = '<div'
    options.collect {|key,val| str << " #{key}=\"#{val}\"" }
    str << '><div class="box_top"></div>'
    str << "\n"
    
    concat(str, content.binding)
    yield(content)
    concat('<br class="clear" /><div class="box_bottom"></div></div>', content.binding)
  end


def nav_tab(name, options={})
  #options[:class] is the class to assing to the li label
  #the class for the link label is set directly to "secund" as you can see
  classes = [options.delete(:class)]
  if(session[:current_tab] && session[:current_tab]==name )
    classes << 'current'
  end
  "<li class='#{classes.join(' ')}'>" + link_to( "<span>"+name+"</span>", options.delete(:url), :class => "secund") + "</li>"
end

 def get_attachment_content_type(post)
  type = CMS::AttachmentFu.find(post.content_id).content_type
  return type
end

  def get_attachment_image(content_type)
    case content_type
      when "image/jpeg"
       return "jpg.jpg"
      when "application/pdf"
       return "pdf_icon.gif"
      when "application/vnd.ms-powerpoint"  
       return "ppt.png"
     else 
       return "clip.jpeg"
    end
  end
end
