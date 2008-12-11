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
  image_tag("/images/yes.png",:border=>0)
 else 
 image_tag("/images/delete22.png",:border=>0)
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
  id= [options.delete(:id)]
  if(session[:current_tab] && session[:current_tab]==name )
    classes << 'current'
  end
  if classes == nil || ( classes.length==1 && classes[0]==nil)
    "<li>" + link_to( "<span>"+name+"</span>", options.delete(:url), :id=>id) + "</li>"
  else
    "<li class='#{classes.join(' ')}'>" + link_to( "<span>"+name+"</span>", options.delete(:url), :id=>id) + "</li>"
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
  usuario = entry.agent
  number_comments= " (" + get_number_children_comments(entry).to_s + ")"
  if usuario
    user = (usuario.login unless usuario.profile).to_s + ((usuario.profile.name + " " +  usuario.profile.lastname) if usuario.profile).to_s
  else
    user = "nonexistent"
  end
 # user += (usuario.profile.name + " " +  usuario.profile.lastname) if usuario.profile
  tags = "[" + entry.content.tag_list + "]"
  fecha = get_format_date(entry)
  if usuario
    user_link = to_user_link(name_format(user,17,""),usuario,space)
  else
    user_link = user
  end
  line_one = ("<div class='post'><p><span class = 'first_Column'>"+ user_link  + to_article_link(number_comments,space,entry) + ":</span><span class = 'second_Column'><span class = 'tags_column'>" + name_format(tags,21,"]")+ "</span><span id = 'post_title_list'>"  + to_article_link(name_format(entry.content.title.to_s ,(size_post(38,21,tags.to_s.length)) ,""),space,entry)).to_s + "</span><span class = 'description'>" + to_article_link(name_format2(": "+ entry.content.text ,(68 - entry.content.title.to_s.length - tags.to_s.length) ,"</p>"),space,entry).to_s  + "</span>" +"</span><span class = 'third_Column'>" + to_article_link(fecha.to_s,space,entry) + "</span> " 
  image = "<span class = 'clip'>" + (to_article_link((image_tag("clip2.gif")),space,entry) unless entry.children.select{|c| c.content.is_a? Attachment} == []).to_s + "</span>"
  edita = ""
  delete = ""
  args.each do |arg|  # obtengo los argumentos variables
  if entry.authorizes?(current_user, :edit) && arg == "edit"
     edita = link_to(image_tag("edit16.png"),edit_space_article_path(@space, entry.content), :title=>"Edit Post").to_s
     # iconos += "<span class = 'mini_image'>" + link_to(image_tag("modify.gif"),edit_space_article_path(@space, entry.content), :title=>"Edit Post").to_s + "</span> "
    end
  if entry.authorizes?(current_user, :destroy) &&  arg == "destroy"
      delete = link_to(image_tag("delete16.png"), space_article_path(@space, entry.content), :confirm => 'Are you sure?', :method => :delete, :title=>"Delete Post").to_s
      #iconos += "<span class = 'clip'>" + link_to(image_tag("delete.gif"), space_article_path(@space, entry.content), :confirm => 'Are you sure?', :method => :delete, :title=>"Delete Post").to_s + "</span>" 
   end
  end
  
  iconos = "<span class = 'mini_image'>" + edita + "</span><span class = 'clip'>" + delete + "</span>" 
  
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
 
  def size_post(number, limit, other_size)
    if other_size > limit
      return number
    else
      return number + limit - other_size
    end
  end
  
  def to_user_link (name,usuario,space)
    return link_to(name,user_path(usuario, :space_id => space.name))
  end
  
    def to_article_link (name,space,entry)
    return link_to(sanitize(name), polymorphic_path([space, entry.content]))
  end
  
  def generate_user_table
    name = "<div class='name'> Name / Lastname</div>"
    organization = "<div class='organization'> Organization </div>"
    interests = "<div class='interests'> Interests </div>"
    members = "<div class='members'> Member of </div> "
    line = name + organization + interests + members + "<br/> <br/>"
    return line
    
  end
  def show_list_user(user)
    div_user = "<div class= 'name'>" + highlight(name_format(  ((user.profile.name if user.profile).to_s + (user.login unless user.profile).to_s )  + ( " " + user.profile.lastname if user.profile).to_s,25,""),@query) + "</div>"
    div_organization = "<div class= 'organization'>" + highlight((name_format(user.organization ,15,"") if user.profile).to_s,@query) + "</div>"
    div_interests = "<div class= 'interests'>" + highlight((name_format(user.tag_list ,23,"")).to_s,@query) + "</div>"
    div_members = "<div class= 'members'>" + highlight((name_format(member_spaces(user) ,15,"")).to_s,@query) + "</div>"
    line = div_user + div_organization + div_interests + div_members + "<br/> <br/>"
    return line
  end
  
  def member_spaces(user)

    if user.stages.length== 0
      return "none"
  else
    return user.stages.map(&:name).join(",")
  end
 end
 
 def generate_event_table
    title = "<span class='event_title'>Event Title </span>"
    description = "<span class='event_description'> Event Description </span>"
    start_date= "<span class='event_start_date'> Start Date </span>"
    tags = "<span class='event_tags'> Tags </span> "
    actions = "<span class='event_actions'> Actions </span> "
    
    line = "<div class='event_div_title'>" + title + description + start_date +  tags + actions + "</div> <br/>"
    return line
  end
  
   def show_event(event)
    span_title = "<span class= 'event_title'>" + link_to_remote(highlight(name_format(event.name,22,""),@query), { :url => formatted_space_event_url(@space, event, "js"), :method => "get"  } ) + "</span>"
    span_description = "<span class= 'event_description'>" + link_to_remote(highlight(name_format(event.description,23,""),@query), { :url => formatted_space_event_url(@space, event, "js"), :method => "get"  } )  + "</span>"
    span_start_date= "<span class= 'event_start_date'>" +  link_to_remote(event.event_datetimes[0].start_date.to_formatted_s(:short), { :url => formatted_space_event_url(@space, event, "js"), :method => "get"  } )  + "</span>"
    span_tags = "<span class= 'event_tags'>" + link_to_remote(highlight(name_format("[" + event.tag_list + "]",30,"]"),@query), { :url => formatted_space_event_url(@space, event, "js"), :method => "get"  } )  + "</span>"
    
        if logged_in? && event.authorizes?(current_user, :edit)
    span_actions = "<span class= 'event_actions'>" + link_to(image_tag("/images/calendar.png"), formatted_space_event_path(@space, event, "ical"), :title=> "Export Ical") + link_to(image_tag("/images/edit22.png"), edit_space_event_path(@space, event), :title=>"Edit event") + link_to(image_tag("/images/delete22.png"), space_event_path(@space, event), :method => :delete, :confirm => "This action will delete the whole event, not only this datetime.\n Are you sure?", :title=>'Delete event')+"</span>"
        else
    span_actions = "<span class= 'event_actions'>   </span>"
        end   
    line = "<div class='event_div'>" + span_title + span_description + span_start_date  + span_tags  +  span_actions + "</div>"
    return line
  end
  
  def show_latest_event(event)
    span_start_date= "<span class= 'sidebar_events_start_date'>" +  event.event_datetimes[0].start_date.strftime('%Y/%m/%d')  + "</span>"
    span_title = "<span class= 'sidebar_events_title'>" + link_to_remote(highlight(name_format(event.name,17,""),@query), { :url => formatted_space_event_url(@space, event, "js"), :method => "get"  } ) + "</span>"
    
    line =  span_start_date  + "&nbsp; "  +  span_title 
    return line
  end
  
  def show_latest_news(entry,space)
    span_title= "<span class= 'sidebar_news_title'> - " + link_to((name_format2(entry.content.title.to_s,25,"")),space_article_path(space,entry.content))   + "</span>"
    span_description = "<span class= 'sidebar_news_description'>" + link_to((name_format2(entry.content.text.to_s,25,"</p>")),space_article_path(space,entry.content)) + "</span>"
    
    line =  span_title  + "&nbsp; "  +  span_description
    return line
  end

def name_format2(name,number,corchete)
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
end
