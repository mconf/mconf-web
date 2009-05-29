module PostsHelper
  def get_edit_route(comment)
    if params[:action] == "show"
      if !comment.attachments.empty? 
        if !comment.attachments.select{|a| a.image?}.empty?     
          space_post_path(comment.space, params[:id] ? params[:id] : comment.id,:edit => comment.id, :form => 'photos')
        else
          space_post_path(comment.space, params[:id] ? params[:id] : comment.id,:edit => comment.id, :form => 'docs')
        end
      else
        space_post_path(comment.space, params[:id] ? params[:id] : comment.id,:edit => comment.id)
      end
    else
      if !comment.attachments.empty? 
        if !comment.attachments.select{|a| a.image?}.empty?     
          space_posts_path(comment.space, :edit => comment.id, :form => 'photos')
        else
          space_posts_path(comment.space, :edit => comment.id, :form => 'docs')
        end
      else
        space_posts_path(comment.space, :edit => comment.id)
      end
    end
  end
  
  def get_reply_route(post,form='')
    if params[:action] == "show"
      space_post_path(post.space, params[:id],:reply_to => post.id, :form => form)
    else
      space_posts_path(post.space, :reply_to => post.id, :form => form)
    end
  end
  
  def first_words( text, size )
    return truncate(text, size, "...")

    #!!!! WARNING !!!
    if text.length > size
      cutted_text = text[0..size]
      cutted_text.chop! until cutted_text[-1,1] == " "
      cutted_text.chop!
      cutted_text << "..."
    else
      text
    end
  end
  
  def thread_title(post)
    post.parent_id.nil? ? post.title : post.parent.title
  end
  
  def thread(post)
    post.parent_id.nil? ? post : post.parent
  end
  
end
