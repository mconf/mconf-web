class Attachment < ActiveRecord::Base
  acts_as_content :has_media => :attachment_fu
  has_attachment :max_size => 4.megabyte

  belongs_to :db_file

  alias_attribute :media, :uploaded_data
  
  validates_as_attachment
  # Implement atom_entry_filter for AtomPub support
  # Return hash with content attributes
  def self.atom_entry_filter(entry)
    # Example:
    # { :body => entry.content.xml.to_s }
    {}
  end
end
