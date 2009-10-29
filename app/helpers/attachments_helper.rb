module AttachmentsHelper
  def table_actions(attachment)
    html = ""
    html << link_to(image_tag("icons/cancel.png", :alt => t('delete'),:class=>"icon"), space_attachment_path(@space,attachment, :version => attachment.version), {:method => :delete, :title => t('attachment.delete'), :confirm => t('delete.confirm', :element => t('attachment.one'))}) if attachment.authorize?(:delete, :to => current_user)
    html << link_to("NV")
    html << link_to(image_tag("icons/comment.png", :alt => t('post.one'),:class=>"icon"), space_post_path(@space,attachment.post)) if attachment.post.present?
    html << link_to(image_tag("icons/date.png", :alt => t('date.one'),:class=>"icon"), space_event_path(@space,attachment.event)) if attachment.event.present?
    html
  end
  
  def sortable_header(title,column)
    html = title
    html << " "
    html << link_to("DESC", space_attachments_path(@space, :order => column, :direction => 'desc', :expand_versions => params[:expand_versions]), :class => "sortable desc#{"_active" if (params[:direction] == 'desc' and column == params[:order]) }" )
    html << " "
    html << link_to("ASC", space_attachments_path(@space, :order => column, :direction => 'asc', :expand_versions => params[:expand_versions]), :class => "sortable desc#{"_active" if (params[:direction] == 'asc' and column == params[:order]) }" )
    html  
  end
  
  def version_attachment(attachments,versioned_attachment_ids)
    att_version_array = attachments.clone

    if versioned_attachment_ids.present?
      versioned_attachment_ids.each do |id|
        if attachments.map(&:id).include?(id.to_i)
          attachment = Attachment.find(id.to_i)
          index = att_version_array.index(attachment)
          att_version_array[index] = attachment.versions.reverse
          att_version_array.flatten!
        end
      end
    end

    att_version_array 
  end
end
