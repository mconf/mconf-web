class Attachment < ActiveRecord::Base
  attr_accessor :post_title, :post_text
  
  has_many :post_attachments, :dependent => :destroy
  has_many :posts, :through => :post_attachments
  belongs_to :space
  belongs_to :event
  belongs_to :author, :polymorphic => true
  
  def version_posts
    post_attachments.version(version).map(&:post)
  end
  
  def post
    version_posts.first
  end
  
  has_attachment :max_size => 1000.megabyte,
                 :path_prefix => 'attachments',
                 :thumbnails => { 'post' => '96x96>',
                                  '16' => '16x16',
                                  '32' => '32x32'}

  # Define this authorization method before acts_as_content to priorize it
  #
  # Deny all requests except reading an already saved attachment in a space that hasn't repository
  # Otherwise, we'll check permissions below
  authorizing do |agent, permission|
    false unless space.repository? || ( permission == :read && ! new_record? )
  end

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
  
  
  
  after_validation do |attachment|
    e = attachment.errors.clone
    attachment.errors.clear
    error_no_file =0
    others_errors = []
    e.each() do |attr,msg| 
      if (attr == "size" && (msg==I18n.t('activerecord.errors.messages.blank')||msg ==I18n.t('activerecord.errors.messages.inclusion')))||(attr=="content_type" && msg==I18n.t('activerecord.errors.messages.blank'))||(attr=="filename" && msg==I18n.t('activerecord.errors.messages.blank'))
        error_no_file+=1      
      else       
        attachment.errors.add(attr,msg)
      end
    end  
    if error_no_file==4
      attachment.errors.add("upload_data",I18n.t('activerecord.errors.messages.missing'))
    end      
  end
  
  after_save do |attachment|
    if attachment.post_title.present?
      p = Post.new(:title => attachment.post_title, :text => attachment.post_text)
      p.author = attachment.author
      p.space = attachment.space
      p.save!
      
      pa = attachment.post_attachments.new(:post => p, :attachment_version => attachment.version)
      pa.save!
    end
  end
  
  def thumbnail_size
    thumbnails.find_by_thumbnail("post").present? ? "post" : "32"
  end
  
  def get_size()
    return " " + (self.size/1024).to_s + " kb" 
  end
  
  authorizing do |agent, permission|
    parent.authorize?(permission, :to => agent) if parent.present? 
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
  
  protected
  def validate
    errors.add(:post_title, I18n.t('activerecord.errors.messages.blank')) if post_text.present? && post_title.blank?   
  end
  
end
