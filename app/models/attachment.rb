class Attachment < ActiveRecord::Base
  belongs_to :post
  belongs_to :space
  belongs_to :event
  belongs_to :author, :polymorphic => true
  
  accepts_nested_attributes_for :post
  
  has_attachment :max_size => 1000.megabyte,
                 :path_prefix => 'attachments',
                 :thumbnails => { 'post' => '96x96>',
                                  '16' => '16x16',
                                  '32' => '32x32'}
  acts_as_resource :has_media => :attachment_fu
  acts_as_taggable
  versioned
  acts_as_content :reflection => :space
  
  validates_as_attachment
  
  named_scope :sorted, lambda { |order, direction|
    { :order => sanitize_order_and_direction(order, direction) }
  }
  
  is_indexed :fields => ['filename', 'type'],
             :include =>[{:class_name => 'Tag',
             :field => 'name',
             :as => 'tags',
             :association_sql => "LEFT OUTER JOIN taggings ON (attachments.`id` = taggings.`taggable_id` AND taggings.`taggable_type` = 'Attachment') LEFT OUTER JOIN tags ON (tags.`id` = taggings.`tag_id`)"},
             { :class_name => 'User',
               :field => 'login',
               :as => 'author',
               :association_sql => "LEFT OUTER JOIN users ON (attachments.`author_id` = users.`id` AND attachments.`author_type` = 'User') "}
  ]
  
  
  before_validation_on_create do |attachment|
    if attachment.post.present?
      if attachment.post.title.blank? && attachment.post.text.blank?
        attachment.post = nil
      else
        attachment.post.author = attachment.author
        attachment.post.space = attachment.space
      end
    end
  end
  
  def thumbnail_size
    thumbnails.find_by_thumbnail("post").present? ? "post" : "32"
  end
  
  def get_size()
    return " " + (self.size/1024).to_s + " kb" 
  end
  
  def auth_delegate
    parent.present? ?
    parent :
    post
  end
  
  authorizing do |agent, permission|
    auth_delegate.authorize? permission, :to => agent
  end
  
  # Implement atom_entry_filter for AtomPub support
  # Return hash with content attributes
  def self.atom_entry_filter(entry)
    # Example:
    #{ :body => entry.content.xml.to_s }
    {}
  end
  
  def current_data
    File.file?(full_filename) ? File.read(full_filename) : nil
  end
  
  #Disable attachment_fu method, wich delete an attachment when attachment is updated
  def rename_file
  end
  
  def partitioned_path(*args)
   ("%08d" % attachment_path_id).scan(/..../) + ["/v#{version}/"] + args
  end
  
  #Destroy all versions when destroy
  def after_destroy
    FileUtils.rm_rf(RAILS_ROOT + "/attachments/#{id}/")
  end
  
  def logo_image_path_with_thumbnails(options = {})
    options[:size] ||= 16
    
    thumbnail_logo_image?(options) ?
    [ self, { :format => format, :thumbnail => options[:size], :version => version } ] :
    logo_image_path_without_thumbnails(options)
  end
  
  # Is there a logo_image_path available?
  def thumbnail_logo_image?(options)
    # FIXME: this is only for AttachmentFu
    ! new_record? &&
    respond_to?(:attachment_options) &&
    attachment_options[:thumbnails].keys.include?(options[:size].to_s) &&
    thumbnails.find_by_thumbnail(options[:size].to_s).present? &&
    version == thumbnails.find_by_thumbnail(options[:size].to_s).version
    
  end
  
  # Sanitize user send params
  def self.sanitize_order_and_direction(order, direction)
    default_order = 'updated_at'
    default_direction = "DESC"
    
    # Remove all but letters and dots
    # filename if author
    order = (order && order!='author') ? order.gsub(/[^\w\.]/, '') : default_order
    
    direction = direction && %w{ ASC DESC }.include?(direction.upcase) ?
    direction :
    default_direction
    
    "#{ order } #{ direction }"
  end
end
