class Blog < ActiveRecord::Base
  acts_as_content 
  acts_as_container #:title => :name

  # Implement atom_entry_filter for AtomPub support
  # Return hash with content attributes
  def self.atom_entry_filter(entry)
    # Example:
    # { :body => entry.content.xml.to_s }
    {}
  end
end