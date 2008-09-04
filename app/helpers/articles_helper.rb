module ArticlesHelper
 def get_number_children_comments(post)
  return post.children.select{|c| c.content.is_a? Article}.size
end

 def get_attachment_children(post)
  return post.children.select{|c| c.content.is_a? Attachment}
   end

end
