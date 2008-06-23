class Article < CMS::Text
  acts_as_content 
  acts_as_ferret :fields => {  
    :title=> {:store => :yes} ,
    :description=> {:store => :yes} ,
    :text=> {:store => :yes} ,
    :tags=> {:store => :yes} ,
  }
  
  
  def title    
    @post = CMS::Post.find_by_content_type_and_content_id("CMS::Text", self.id)
    return @post.title
  end
  
  def description    
    @post = CMS::Post.find_by_content_type_and_content_id("CMS::Text", self.id)
    return @post.description
  end
  
  
  def tags
    @post = CMS::Post.find_by_content_type_and_content_id("CMS::Text", self.id)
    return @post.tag_list if @post.tag_list
  end
end
