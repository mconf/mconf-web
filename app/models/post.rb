class Post < ActiveRecord::Base
  acts_as_resource
  acts_as_content :entry => true
  acts_as_taggable

  is_indexed :fields => ['text','title'],:concatenate => [
{:class_name => 'Tag',
:field => 'name',
:as => 'tags',
:association_sql => "LEFT OUTER JOIN taggings ON (posts.`id` = taggings.`taggable_id` AND taggings.`taggable_type` = 'Post') LEFT OUTER JOIN tags ON (tags.`id` = taggings.`tag_id`)"
}]

  delegate :public_read, :to => :entry
  def public_read=(value)
    entry.public_read = value
  end
  before_save :public_read_ñapa
  def public_read_ñapa
    @_stage_performances = entry.public_read ?
      [ 
        { :role_id => Role.without_stage_type.find_by_name("Reader").id,
          :agent_id => Anyone.current.id,
          :agent_type => Anyone.current.class.base_class.to_s
        } 
      ] :
      Array.new
  end

    validates_presence_of :title, :text
 # is_indexed :fields => ['text','title']#,

  def attachments
    entry.children.select{|c| c.content.is_a? Attachment}
  end
  
#  :include => [{:class_name => 'Entry', :field => 'title', :association_sql => "" }],
 # :include => [{:class_name => 'Tag', :field => 'name', :association_sql => "JOIN taggings ON taggings.tag_id = tags.id" }]
  
 def self.atom_parser(data)
=begin     
{"post"=>{"title"=>"prueba", "text"=>"<p>prueba 2</p>"}, "commit"=>"Create", "last_post"=>"2", 
"tags"=>"tag1, tag2, tag3", "action"=>"create", 
"attachment0"=>{"uploaded_data"=>#<ActionController::UploadedStringIO:0xb57a1510>}, 
"controller"=>"posts", "attachment1"=>{"uploaded_data"=>#<ActionController::UploadedStringIO:0xb57a118c>},
 "entry"=>{"public_read"=>"1"}, "space_id"=>"2"}
=end

    resultado = {}
    e = Atom::Entry.parse(data)
    post = {}
    post[:title] = e.title.to_s
    post[:text] = e.content.to_s
    
    resultado[:last_post] = 0
    
    resultado[:post] = post
   
    t = []
    e.categories.each do |c|
      unless c.scheme
        t << c.term
      end
    end
    
    entry = {}

=begin
    parent_post_id = e.get_elem(e.to_xml, 'http://sir.dit.upm.es/schema', 'parent_id').text.to_i


    if parent_post_id && parent_post_id != 0
      parent_entry_id = Post.find(parent_post_id).entry.id 
      resultado[:comment] = true
      entry[:parent_id] = parent_entry_id
    end
=end   

    ### esto es para cumplir con atom-threading
    if in_reply_to = e.get_elem(e.to_xml, 'http://purl.org/syndication/thread/1.0', 'in-reply-to')
      parent_entry_id = Post.find(in_reply_to.text.to_i).entry.id 
      resultado[:comment] = true
      entry[:parent_id] = parent_entry_id
   end
    #if the post is a comment, no public_read is given
    unless entry[:comment]
    vis = e.get_elem(e.to_xml, "http://schemas.google.com/g/2005", "visibility").text
    if vis == "public" 
    entry[:public_read] = true
    else
    entry[:public_read] = false
    end
  end
  
    resultado[:entry] = entry
    resultado[:tags] = t.join(sep=",")

    return resultado     
  end    
  
  
end
