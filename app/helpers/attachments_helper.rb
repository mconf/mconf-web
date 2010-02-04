module AttachmentsHelper
  def table_actions(row, attachment, interactive)
    #html = ""
    #html << link_to(image_tag("icons/cancel.png", :alt => t('delete'),:class=>"icon"), space_attachment_path(@space,attachment, :version => attachment.version), {:method => :delete, :title => t('attachment.delete'), :confirm => t('delete.confirm', :element => t('attachment.one'))}) if attachment.authorize?(:delete, :to => current_user)
    #html << link_to("NV")
    #html << link_to(image_tag("icons/comment.png", :alt => t('post.one'),:class=>"icon"), space_post_path(@space,attachment.post)) if attachment.post.present?
    #html << link_to(image_tag("icons/date.png", :alt => t('date.one'),:class=>"icon"), space_event_path(@space,attachment.event)) if attachment.event.present?
    #html
    
    html=""
    html << if interactive && attachment.authorize?(:update,:to => current_user)
              attachment.tags.size>0 ? (link_to(image_tag("icons/edit_tag.png", :title=> t('tag.edit')),edit_tags_space_attachment_path(@space, attachment), :class=>"repository_sidebar_action no-dot")) : (link_to(image_tag('icons/add_tag.png', :title => t('tag.add')), edit_tags_space_attachment_path(@space, attachment), :class=>"repository_sidebar_action no-dot"))
            else
              image_tag("icons/edit_tag.png", :title=>t('login_request' + 'tag.edit'),:class=>"icon fade")
            end
    html << if attachment.authorize?(:read,:to => current_user)
              link_to(image_tag("icons/download_doc20.png", :title => t('download'),:class=>"icon"), space_attachment_path(@space,attachment, :format => attachment.format!), :class=>"no-dot")
          else
              image_tag("icons/download_doc20.png", :title => t('login_request' + 'download'),:class=>"icon fade")
            end
    if attachment.authorize?(:delete, :to => current_user)
      html << link_to(image_tag("icons/delete_doc20.png", :title => t('delete.one'), :class =>"icon can_delete"), space_attachment_path(@space,attachment), {:method => :delete, :confirm => t('delete.confirm', :element => t('attachment.one'))}, :class=>"no-dot")
      row[:class] += " can_delete"
    else
      html <<  image_tag("icons/delete_doc20.png", :title => t('delete.one'), :class =>"icon fade")
    end
    html << if interactive && attachment.current_version? && attachment.authorize?(:update,:to => current_user)
            link_to(image_tag("icons/new_version_doc20.png", :title=> t('login_request'), :class=>"icon"), edit_space_attachment_path(@space, attachment), :class => "repository_sidebar_action no-dot")
            else
          image_tag("icons/new_version_doc20.png", :title=> t('login_request'), :class=>"icon fade")
            end
    html
   
  end
  
  def sortable_header(title,column)
    html = title
    html << " "
    html << link_to(((params[:direction] == 'desc' and column == params[:order]) ? image_tag("down_or.png") : image_tag("down.png")), path_for_attachments({:order => column, :direction => 'desc'}), :class => "sortable table_params desc#{"_active" if (params[:direction] == 'desc' and column == params[:order]) }" )
    html << " "
    html << link_to(((params[:direction] == 'asc' and column == params[:order]) ? image_tag("up_or.png") : image_tag("up.png")), path_for_attachments({:order => column, :direction => 'asc'}), :class => "sortable table_params desc#{"_active" if (params[:direction] == 'asc' and column == params[:order]) }" )
    html  
  end
  
  def version_attachment(attachments)
    
    versioned_attachment_ids = expand_versions_to_array
    
    att_version_array = attachments.clone

    if versioned_attachment_ids.present?
      versioned_attachment_ids.each do |id|
        if attachments.map(&:version_family_id).include?(id.to_i)
          family = Attachment.version_family(id.to_i)
          attachment = (family & attachments).first
          index = att_version_array.index(attachment)
          att_version_array[index] = family
          att_version_array.flatten!
        end
      end
    end

    att_version_array 
  end
  
  def path_for_attachments(p={})
    direction = p[:direction].present? ? p[:direction] : params[:direction]
    order = p[:order].present? ? p[:order] : params[:order]
    query = p[:query].present? ? p[:query] : params[:query]
    expand_versions=expand_versions_to_array - [p[:not_expanded]] + [p[:expanded]]
    tags = tags_to_array - [p[:rm_tag]] + [p[:add_tag]]
    if @space.nil?
      url_for(:direction => direction, :order => order, :query => query, :expand_versions => expand_versions.uniq.join(","), :tags => tags.uniq.join(","))
    else
      url_for(:space_id => @space,:direction => direction, :order => order, :query => query, :expand_versions => expand_versions.uniq.join(","), :tags => tags.uniq.join(","))
    end
      
  end
  
  def options_for_fcbkcomplete(collection,value,text,selected=nil)
    html=""
    collection.each do |t|
      html << %(<option value="#{t.send(value)}"#{"class=selected" if selected.include?(t)}>#{t.send(text)}</option>)
    end
    html
  end
  
  def attachment_link(attachment)
    link_to truncate(attachment.filename, :length => 28),space_attachment_path(attachment.space,attachment, :format => attachment.format!), :title => attachment.filename
  end
  
  private
  
  def expand_versions_to_array
    params[:expand_versions].present? ? params[:expand_versions].split(",").map(&:to_i) : Array.new
  end
  
  def tags_to_array
    params[:tags].present? ? params[:tags].split(",").map(&:to_i) : Array.new
  end
  
  def tags_list tag_array
    html = "<ul class=\"holder\">"
    tag_array.each do |tag|
      html << "<li class=\"w-cross\">#{tag.name}</li>"
    end
    html << "</ul>"
  end
  
  def tag_count(elements, less=[], p={})
    order = p[:order] || "popularity"
    
    tags_with_duplicates = elements.map(&:tags).flatten.compact - less
    
    #Count elements
    count = Hash.new(0)
    tags_with_duplicates.each do |tag|
      count[tag] += 1
    end

    case order
    when "abc"
      count.keys.sort{|x,y| x.name <=> y.name }.map{|t| {:tag=> t, :count => count[t]}}
    else
      count.keys.sort{|x,y| count[y] <=> count[x]}.map{|t| {:tag=> t, :count => count[t]}}
    end
    
  end
end
