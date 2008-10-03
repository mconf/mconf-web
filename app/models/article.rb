class Article < ActiveRecord::Base
  acts_as_content 
  acts_as_ferret :fields => {  
    :title=> {:store => :yes} ,
    :text=> {:store => :yes} ,
    :tags=> {:store => :yes} ,
  }
  
    acts_as_taggable

    validates_presence_of :title, :text
 # is_indexed :fields => ['text','title']#,
  
#  :include => [{:class_name => 'Entry', :field => 'title', :association_sql => "" }],
 # :include => [{:class_name => 'Tag', :field => 'name', :association_sql => "JOIN taggings ON taggings.tag_id = tags.id" }]
  

   def authorizes?(agent, actions)
    return true if agent.superuser || self.entry.has_role_for?(agent, :admin)
    
     actions = Array(actions)

    if actions.delete(:edit)
      return true if self.entry.agent == agent 
    end
    
    false
  end
  
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
    vis = e.get_elem(e.to_xml, "http://schemas.google.com/g/2005", "visibility").text
    if vis == "public" 
    entry[:public_read] = 1
    else
    entry[:public_read] = 0
  end
  
    resultado[:entry] = entry
    resultado[:tags] = t.join(sep=",")

    return resultado     
  end    
  
  
end
