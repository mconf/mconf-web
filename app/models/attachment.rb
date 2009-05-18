class Attachment < ActiveRecord::Base
  belongs_to :db_file
  belongs_to :post

  has_attachment :max_size => 10.megabyte,
                 :thumbnails => { :post => '96x96>'}
  acts_as_resource :has_media => :attachment_fu
  acts_as_taggable

  validates_as_attachment

  def post_thumbnail()
    return self.thumbnails.select{|thumb| thumb.thumbnail== "post"}.first
  end
  
  def get_size()
    return " " + (self.size/1024).to_s + " kb" 
  end

  def local_affordances
    parent ?
      parent.affordances :
      post.affordances
  end

  # Implement atom_entry_filter for AtomPub support
  # Return hash with content attributes
  def self.atom_entry_filter(entry)
    # Example:
    #{ :body => entry.content.xml.to_s }
    {}
  end
end
