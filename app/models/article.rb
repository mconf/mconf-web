class Article < ActiveRecord::Base
  acts_as_content 
  acts_as_container :title => :name  ###probando
   

  # Implement atom_entry_filter for AtomPub support
  # Return hash with content attributes
  def self.atom_entry_filter(entry)
    # Example:
    # { :body => entry.content.xml.to_s }
    {}
  end
  
  def title
    CMS::Post.find_by_content_id(id).title
  end
end

