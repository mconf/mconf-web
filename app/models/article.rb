class Article < XhtmlText
  acts_as_content 
  acts_as_ferret :fields => {  
    :title=> {:store => :yes} ,
    :description=> {:store => :yes} ,
    :text=> {:store => :yes} ,
    :tags=> {:store => :yes} ,
  }
  
  
  def title    
    @post = Post.find_by_content_type_and_content_id("XhtmlText", self.id)
    return @post.title
  end
  
  def description    
    @post = Post.find_by_content_type_and_content_id("XhtmlText", self.id)
    return @post.description
  end
  
  
  def tags
    @post = Post.find_by_content_type_and_content_id("XhtmlText", self.id)
    return @post.tag_list.collect {|tag| tag} if @post.tag_list
  end
end
