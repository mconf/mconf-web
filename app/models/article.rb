class Article < ActiveRecord::Base
  acts_as_content  
    acts_as_taggable

  is_indexed :fields => ['text','title'],:concatenate => [
{:class_name => 'Tag',
:field => 'name',
:as => 'tags',
:association_sql => "LEFT OUTER JOIN taggings ON (articles.`id` = taggings.`taggable_id` AND taggings.`taggable_type` = 'Article') LEFT OUTER JOIN tags ON (tags.`id` = taggings.`tag_id`)"
}]
  #,


    validates_presence_of :title, :text
 # is_indexed :fields => ['text','title']#,

  
#  :include => [{:class_name => 'Entry', :field => 'title', :association_sql => "" }],
 # :include => [{:class_name => 'Tag', :field => 'name', :association_sql => "JOIN taggings ON taggings.tag_id = tags.id" }]
  
 def self.atom_parser(data)
=begin     
{"article"=>{"title"=>"prueba", "text"=>"<p>prueba 2</p>"}, "commit"=>"Create", "last_post"=>"2", 
"tags"=>"tag1, tag2, tag3", "action"=>"create", 
"attachment0"=>{"uploaded_data"=>#<ActionController::UploadedStringIO:0xb57a1510>}, 
"controller"=>"articles", "attachment1"=>{"uploaded_data"=>#<ActionController::UploadedStringIO:0xb57a118c>},
 "entry"=>{"public_read"=>"1"}, "space_id"=>"2"}
=end

    resultado = {}
    e = Atom::Entry.parse(data)
    article = {}
    article[:title] = e.title.to_s
    article[:text] = e.content.to_s
    
    resultado[:last_post] = 0
    
    resultado[:article] = article
   
    t = []
    e.categories.each do |c|
      unless c.scheme
        t << c.term
      end
    end
    
    entry = {}

=begin
    parent_article_id = e.get_elem(e.to_xml, 'http://sir.dit.upm.es/schema', 'parent_id').text.to_i


    if parent_article_id && parent_article_id != 0
      parent_entry_id = Article.find(parent_article_id).entry.id 
      resultado[:comment] = true
      entry[:parent_id] = parent_entry_id
    end
=end   

    ### esto es para cumplir con atom-threading
    if in_reply_to = e.get_elem(e.to_xml, 'http://purl.org/syndication/thread/1.0', 'in-reply-to')
      parent_entry_id = Article.find(in_reply_to.text.to_i).entry.id 
      resultado[:comment] = true
      entry[:parent_id] = parent_entry_id
   end
    #if the article is a comment, no public_read is given
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
