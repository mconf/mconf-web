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
  if classes == nil || ( classes.length==1 && classes[0]==nil)
    "<li>" + link_to( "<span>"+name+"</span>", options.delete(:url)) + "</li>"
  else
    "<li class='#{classes.join(' ')}'>" + link_to( "<span>"+name+"</span>", options.delete(:url)) + "</li>"
  end
end


def sub_tab(name, ruta)
  #options[:class] is the class to assing to the li label
  #the class for the link label is set directly to "secund" as you can see
  classes = [] 
  if(session[:current_sub_tab] && session[:current_sub_tab]==name )
    classes << 'current'
  end
  if classes == nil || classes.length==0 || ( classes.length==1 && classes[0]==nil)
    "<li>" + link_to( "<span>"+name+"</span>", ruta) + "</li>"
  else
    "<li class='#{classes.join(' ')}'>" + link_to( "<span>"+name+"</span>", ruta) + "</li>"
  end
end

 def get_attachment_content_type(entry)
  type = Attachment.find(entry.content_id).content_type
  return type
end


  def get_attachment_image(content_type)
    case content_type
      when "image/jpeg"
       return "jpeg.gif"
      when "application/pdf"
       return "pdf.gif"
      when "application/vnd.ms-powerpoint"  
       return "ppt.gif"
      when "video/x-msvideo"  
       return "avi.gif"
      when "audio/x-wav"  
       return "sound.gif"
      when "application/msword"  
       return "doc.gif"       
      when "application/vnd.ms-excel"  
       return "xls.gif"
      when "application/zip"  
       return "zip.gif"
      when "application/octet-stream"  
       return "txt.gif"
       
     else 
       return "generic.gif"
    end
  end
  
  def show_article(entry,space,*args) #return a compress view of a entry post
 
  usuario = User.find(entry.agent_id) 
  number_comments= "(" + get_number_children_comments(entry).to_s + ")"
  user = usuario.login unless usuario.profile
  user += (usuario.profile.name + " " +  usuario.profile.lastname) if usuario.profile
  tags = "[" + entry.tag_list + "]"
  fecha = get_format_date(entry)
  line_one = ("<div class='post'> <p> <span class = 'first_Column'> "+ to_user_link(name_format(user,17,""),usuario,space)  + to_article_link(number_comments,space,entry) + ": </span>  <span class = 'second_Column'> <span class = 'tags_column'> " + name_format(tags,21,"]")+ " </span>"  + to_article_link(name_format(entry.title ,(65  - tags.length) ,""),space,entry)).to_s +  "<span class = 'description'> " + to_article_link(name_format(": "+ entry.description ,(80 - entry.title.length - tags.length) ,""),space,entry).to_s  + "</span>" +"</span>  <span class = 'third_Column'>" + to_article_link(fecha.to_s,space,entry) + "</span> " 
  image = "<span class = 'clip'>" + (to_article_link((image_tag("clip2.gif")),space,entry) unless entry.children.select{|c| c.content.is_a? Attachment} == []).to_s + "</span>"
  iconos = ""
  args.each do |arg|  # obtengo los argumentos variables
  if arg == "edit" 
    iconos += "<span class = 'mini_image'>" + link_to(image_tag("modify.gif"),edit_space_article_path(@space, entry.content), :title=>"Edit Post").to_s + "</span> "
  end
  if arg == "destroy"
    iconos += "<span class = 'clip'>" + link_to(image_tag("delete.gif"), space_article_path(@space, entry.content), :confirm => 'Are you sure?', :method => :delete, :title=>"Delete Post").to_s + "</span>" 
  end
  end

  
  line = line_one + " " + image + iconos + " <br/> </p></div>"
  
    return line
    
  end
  
  def get_format_date(entry)
    updated_time = entry.updated_at
    if updated_time.to_date == Time.now.to_date
      return updated_time.to_time.to_formatted_s(:time)
    else 
      return updated_time.to_date.to_formatted_s(:short)
    end
  end
  
   def get_number_children_comments(entry)
  return entry.children.select{|c| c.content.is_a? Article}.size
end

  def name_format(name,number,corchete)
    if number < 0
      return ""
    end
    if name == "[]"
      return ""
    end
    if name.length < number
      return name 
    else
      return name[0,number-4] + "..." + corchete
    end
  end
  
  def to_user_link (name,usuario,space)
    return link_to(name,user_path(usuario,:space_id => space.id))
  end
  
    def to_article_link (name,space,entry)
    return link_to(sanitize(name), polymorphic_path([space, entry.content]))
  end
end
