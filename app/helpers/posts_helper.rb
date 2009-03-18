module PostsHelper
  def get_route(comment)
    if !comment.attachments.empty? 
      if !comment.attachments.select{|a| a.image?}.empty?     
        space_posts_path(@space,:edit => comment, :form => 'photos')
      else
        space_posts_path(@space,:edit => comment, :form => 'docs')
      end
    else
      space_posts_path(@space,:edit => comment)
    end   
  end
end
