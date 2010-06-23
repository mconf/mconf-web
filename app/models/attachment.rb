# Copyright 2008-2010 Universidad Politécnica de Madrid and Agora Systems S.A.
#
# This file is part of VCC (Virtual Conference Center).
#
# VCC is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# VCC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with VCC.  If not, see <http://www.gnu.org/licenses/>.

class Attachment < ActiveRecord::Base
  attr_accessor :post_title, :post_text, :version_parent_id
  attr_reader :version_parent
  
  has_many :post_attachments, :dependent => :destroy
  has_many :posts, :through => :post_attachments
  belongs_to :space
  belongs_to :event
  belongs_to :author, :polymorphic => true
  
  has_attachment :max_size => 1000.megabyte,
                 :path_prefix => 'attachments',
                 :thumbnails => { '16' => '16x16',
                                  '32' => '32x32',
                                  '64' => '64x64',
                                  '128' => '128x128'}
  
  def post
    posts.first
  end
  
  def space
    space_id.present? ?
      Space.find_with_disabled(space_id) :
      nil
  end
  
  # Define this authorization method before acts_as_content to priorize it
  #
  # Deny all requests except reading an already saved attachment in a space that hasn't repository
  # Otherwise, we'll check permissions below
  authorizing do |agent, permission|
    false unless space.repository? || ( permission == :read && ! new_record? )
  end

  acts_as_resource :has_media => :attachment_fu
  acts_as_taggable
  acts_as_content :reflection => :space
  
  validates_as_attachment
   
  def version_family
    Attachment.version_family(version_family_id)
  end
  
  def version
    version_family.reverse.index(self) +1
  end
  
  def current_version?
    version_child_id.nil?
  end
  
  named_scope :version_family, lambda{ |id|
    {:order => 'id DESC',
    :conditions => {:version_family_id => id}}
  }

  named_scope :sorted, lambda { |order, direction|
    { :order => sanitize_order_and_direction(order, direction),
      :conditions => {:version_child_id => nil}}
  }
  
  is_indexed :fields => ['filename', 'type', 'space_id', 'updated_at'],
             :conditions => 'parent_id IS NULL',
             :include => [
               { :class_name => 'Tag',
                 :field => 'name',
                  :as => 'tags',
                  :association_sql => "LEFT OUTER JOIN taggings ON (attachments.`id` = taggings.`taggable_id` AND taggings.`taggable_type` = 'Attachment') LEFT OUTER JOIN tags ON (tags.`id` = taggings.`tag_id`)"},
               { :class_name => 'User',
                 :field => 'login',
                 :as => 'author',
                 :association_sql => "LEFT OUTER JOIN users ON (attachments.`author_id` = users.`id` AND attachments.`author_type` = 'User') "}
             ]
  
  protected
  
  def validate
    errors.add(:post_title, I18n.t('activerecord.errors.messages.blank')) if post_text.present? && post_title.blank?
    if version_parent_id.present?
      @version_parent = Attachment.find(version_parent_id)
      if @version_parent.present?
        self.version_family_id = @version_parent.version_family_id
        errors.add(:version_parent_id, I18n.t('activerecord.errors.messages.taken')) if @version_parent.version_child_id.present?
      else
        errors.add(:version_parent_id, I18n.t('activerecord.errors.messages.missing'))
      end
    end
  end
  
  public
  
  after_validation do |attachment|
    # Replace 4 missing file errors with a unique, more descriptive error
    missing_file_errors = {
      "size"         => [ I18n.t('activerecord.errors.messages.blank'),
                          I18n.t('activerecord.errors.messages.inclusion') ],
      "content_type" => [ I18n.t('activerecord.errors.messages.blank') ],
      "filename"     => [ I18n.t('activerecord.errors.messages.blank') ]
    }

    if attachment.errors.select{ |e| missing_file_errors[e.first].include?(e.last) }.size >= 4
      errors = attachment.errors.clone
      attachment.errors.clear
      attachment.errors.add("upload_data",I18n.t('activerecord.errors.messages.missing'))
      errors.each do |att, msg|
        unless missing_file_errors[att].include?(msg)
          attachment.errors.add(att, msg)
        end
      end
    end
  end
  
  after_create do |attachment|
    unless attachment.thumbnail?
      
      if attachment.version_parent.present?
        parent = attachment.version_parent
        parent.without_timestamps do |p|
          p.update_attribute(:version_child_id, attachment.id)
        end
      else
        attachment.update_attribute(:version_family_id,attachment.id)
      end
    end
    
  end
  
  after_save do |attachment|
    if attachment.post_title.present?
      p = Post.new(:title => attachment.post_title, :text => attachment.post_text)
      p.author = attachment.author
      p.space = attachment.space
      p.attachments << attachment
      p.save!

      attachment.post_title = attachment.post_text = nil
    end
  end
  
  after_destroy do |attachment|
    parents = Attachment.find_all_by_version_child_id(attachment.id)
    parents.each do |parent|
      parent.without_timestamps do |p|
        p.update_attribute(:version_child_id, attachment.version_child_id)
      end
    end
  end
  
  def thumbnail_size
    thumbnails.find_by_thumbnail("post").present? ? "post" : "32"
  end
  
  def get_size()
    return " " + (self.size/1024).to_s + " kb" 
  end
  
  # Return format if Mymetype is present or "all" if not
  def format!
    format ? format : :all
  end
  
  authorizing do |agent, permission|
    parent.authorize?(permission, :to => agent) if parent.present? 
  end

  def current_data
    File.file?(full_filename) ? File.read(full_filename) : nil
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
  
  def self.repository_attachments(container, params)
    attachments = container.attachments.roots.sorted(params[:order],params[:direction])

    space = (container.is_a?(Space) ? container : container.space)
    
    tags = params[:tags].present? ? params[:tags].split(",").map{|t| Tag.in(space).find(t.to_i)} : Array.new
    tags.each do |t|
      attachments = attachments.select{|a| a.tags.include?(t)}
    end
    
    # Filter by attachment_ids
    if params[:attachment_ids].present?
      att_ids = params[:attachment_ids].split(",")
      attachments = attachments.select{|a| att_ids.include?(a.id.to_s)}
    end
    
    attachments.sort!{|x,y| x.author.name <=> y.author.name } if params[:order] == 'author' && params[:direction] == 'desc'
    attachments.sort!{|x,y| y.author.name <=> x.author.name } if params[:order] == 'author' && params[:direction] == 'asc'
    attachments.sort!{|x,y| x.content_type.split("/").last <=> y.content_type.split("/").last } if params[:order] == 'type' && params[:direction] == 'desc'
    attachments.sort!{|x,y| y.content_type.split("/").last <=> x.content_type.split("/").last } if params[:order] == 'type' && params[:direction] == 'asc'
    
    [attachments, tags]
  end
  
  def without_timestamps
    rt = self.class.record_timestamps
    self.class.record_timestamps=false
    yield self
    self.class.record_timestamps=rt
  end  
  
# Author Permissions
  authorizing do |agent, permission|
    if author == agent &&
        permission == :delete  &&
        space.authorize?([ :create, :content ], :to => agent)
      true
    end
  end

end
