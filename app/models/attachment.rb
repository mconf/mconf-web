class Attachment < ActiveRecord::Base
  acts_as_resource :has_media => :attachment_fu
  acts_as_content :entry => true
  has_attachment :max_size => 4.megabyte
  acts_as_taggable
  belongs_to :db_file

  alias_attribute :media, :uploaded_data
  
  validates_as_attachment
  
  before_save do |attachment|
    return unless attachment.entry.parent
    post = attachment.entry.parent.content
    
    attachment._stage_performances = []
    
    post.stage_performances.each do |p|
      attachment._stage_performances << { :role_id => p.role_id,
                                :agent_id => p.agent_id,
                                :agent_type => p.agent_type
                              }
    end
  end
  # Implement atom_entry_filter for AtomPub support
  # Return hash with content attributes
  def self.atom_entry_filter(entry)
    # Example:
    #{ :body => entry.content.xml.to_s }
    {}
  end
end
