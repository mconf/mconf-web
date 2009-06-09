class Post < ActiveRecord::Base
  belongs_to :space
  belongs_to :author, :polymorphic => true
  has_many :attachments, :dependent => :destroy
  belongs_to :event

  acts_as_resource :per_page => 10
  acts_as_content :reflection => :space
  acts_as_taggable
  acts_as_tree :order => 'updated_at ASC'

  named_scope :public, lambda { |arg|
    { :joins => :space,
      :conditions => [ 'public = ?', true ] }
  }

  is_indexed :fields => ['text','title'],
             :include =>[{:class_name => 'Tag',
                          :field => 'name',
                          :as => 'tags',
                          :association_sql => "LEFT OUTER JOIN taggings ON (posts.`id` = taggings.`taggable_id` AND taggings.`taggable_type` = 'Post') LEFT OUTER JOIN tags ON (tags.`id` = taggings.`tag_id`)"},
                          {:class_name => 'User',
                               :field => 'login',
                               :as => 'login_user',
                               :association_sql => "LEFT OUTER JOIN users ON (posts.`author_id` = users.`id` AND posts.`author_type` = 'User') "}#, 
                          #{:class_name => 'Profile',:field=> 'name',:as => 'name_user',:association_sql => "LEFT OUTER JOIN profiles ON (profiles.`user_id` = users.`id`)"},
                          #{:class_name => 'Profile',:field=> 'lastname',:as => 'lastname_user',:association_sql => "LEFT OUTER JOIN profiles ON (profiles.`user_id` = users.`id`)"}
                          ]
            
            


 
  validates_presence_of :title, :unless => Proc.new { |post| post.parent.present? || post.event.present? }
  #validates_presence_of :text, :if => Proc.new { |post| debugger post.attachments.empty?}


  # Update parent Posts when commenting to it
  after_save { |post|
    if post.parent_id
      post.parent.update_attribute(:updated_at, Time.now)
    end
  }
  
  # This method return the 3 last comment of a thread if the thread has more than 3 comments. 
  # If not, return the parent post and their comments
  def three_last_comment()
    return self.children.last(3)
  end
  
  def self.last_news(space)
    return Post.find(:all, :conditions => {:space_id => space, :parent_id => nil}, :order => "updated_at DESC", :limit => 4)
  end
  
  def self.atom_parser(data)
    params = {}
    e = Atom::Entry.parse(data)

    params[:post] = {}
    params[:post][:title] = e.title.to_s
    params[:post][:text] = e.content.to_s
    
    t = []
    e.categories.each do |c|
      unless c.scheme
        t << c.term
      end
    end

    params[:post][:_tags] = t.join(",")

    ### esto es para cumplir con atom-threading
    if in_reply_to = e.get_elem(e.to_xml, 'http://purl.org/syndication/thread/1.0', 'in-reply-to')
      params[:posts][:parent_id] = Post.find(in_reply_to.text.to_i).id 
    end

    #if the post is a comment, no public_read is given
    #TODO: cuando implementemos el hash de visibilidad
    #unless entry[:comment]
    #vis = e.get_elem(e.to_xml, "http://schemas.google.com/g/2005", "visibility").text
    #if vis == "public" 
    #entry[:public_read] = true
    #else
    #entry[:public_read] = false
    #end

    return params 
  end    

  # Additional Permissions
  def local_affordances
    [ ActiveRecord::Authorization::Affordance.new(author, :update),
      ActiveRecord::Authorization::Affordance.new(author, :delete) ]
  end
end
