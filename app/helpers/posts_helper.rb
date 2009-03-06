module PostsHelper
 def get_number_children_comments(entry)
  return entry.children.select{|c| c.content.is_a? Post}.size
end

 def get_attachment_children(entry)
  return entry.children.select{|c| c.content.is_a? Attachment}
   end

end
