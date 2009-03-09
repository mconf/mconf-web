class Post < ActiveRecord::Base
  belongs_to :space
  belongs_to :author, :polymorphic => true
  has_many :attachments, :dependent => :destroy

  acts_as_resource :per_page => 10
  acts_as_content :reflection => :space
  acts_as_taggable
  acts_as_tree :order => 'updated_at DESC'

  is_indexed :fields => ['text','title'],:concatenate => [
    {:class_name => 'Tag',
     :field => 'name',
     :as => 'tags',
     :association_sql => "LEFT OUTER JOIN taggings ON (posts.`id` = taggings.`taggable_id` AND taggings.`taggable_type` = 'Post') LEFT OUTER JOIN tags ON (tags.`id` = taggings.`tag_id`)"
}]

  validates_presence_of :title, :text

  # Update parent Posts when commenting to it
  after_create { |post|
    if post.parent_id
      post.parent.update_attribute(:updated_at, Time.now)
    end
  }

 
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
end
