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
    named_scope :not_events, lambda {
    {:conditions => {:event_id =>  nil} }
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
  
  def author
    case author_type
    when User
      User.find_with_disabled(author_id)
    when NilClass
      Anonymous.current
    else
      author_type.constantize.find author_id
    end
  end
  
  # This method return the 3 last comment of a thread if the thread has more than 3 comments. 
  # If not, return the parent post and their comments
  def three_last_comment()
    return self.children.last(3)
  end
  
  def self.last_news(space)
    return Post.not_events().find(:all, :conditions => {:space_id => space, :parent_id => nil}, :order => "updated_at DESC", :limit => 4)
  end
  
  def self.from_atom(entry)
    params = {}

    params[:title] = entry.title.to_s
    params[:text] = entry.content.to_s

    # Tags
    # TODO: Move to Station plugin
    #t = []
    #e.categories.each do |c|
    #  unless c.scheme
    #    t << c.term
    #  end
    #end
    #params[:_tags] = t.join(",")

    # TODO: fix this
    ### atom-threading support
    #if in_reply_to = entry.get_elem(entry.to_xml, 'http://purl.org/syndication/thread/1.0', 'in-reply-to')
    #  params[:parent_id] = Post.find_by_source_entry_id(in_reply_to.text.to_s).try(:id)
    #end

    #if the post is a comment, no public_read is given
    #TODO: cuando implementemos el hash de visibilidad
    #unless entry[:comment]
    #vis = e.get_elem(e.to_xml, "http://schemas.google.com/g/2005", "visibility").text
    #if vis == "public" 
    #entry[:public_read] = true
    #else
    #entry[:public_read] = false
    #end

    params 
  end    

  # Additional Permissions
  def local_affordances
    [ ActiveRecord::Authorization::Affordance.new(author, :update),
      ActiveRecord::Authorization::Affordance.new(author, :delete) ]
  end
end
