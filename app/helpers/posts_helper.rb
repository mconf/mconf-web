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
  
  def first_words( text, size )
    if text.length > size
      cutted_text = text[0..size]
      cutted_text.chop! until cutted_text[-1,1] == " "
      cutted_text.chop!
      cutted_text << "..."
    else
      text
    end
  end
end
