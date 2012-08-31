# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class Attachment < ActiveRecord::Base
  attr_accessor :post_title, :post_text, :version_parent_id
  attr_reader :version_parent

  has_many :post_attachments, :dependent => :destroy
  has_many :posts, :through => :post_attachments
  belongs_to :space
  belongs_to :event
  belongs_to :author, :polymorphic => true
  belongs_to :agenda_entry


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

  acts_as_resource :has_media => :attachment_fu
  acts_as_taggable
  acts_as_content :reflection => :space

  validate :validates_as_attachment_wrapper
  def validates_as_attachment_wrapper
    Attachment.validates_as_attachment
  end

  def version_family
    Attachment.version_family(version_family_id)
  end

  def version
    version_family.reverse.index(self) +1
  end

  def current_version?
    version_child_id.nil?
  end

  scope :version_family, lambda{ |id|
    where(:version_family_id => id).order('id DESC')
  }

  scope :sorted, lambda { |order, direction|
    where(:version_child_id => nil).order(sanitize_order_and_direction(order, direction))
  }

  protected

  validate :validate_method
  def validate_method
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

  before_validation do |attachment|

    if attachment.agenda_entry_id
      attachment.event = AgendaEntry.find(attachment.agenda_entry_id).event
    end

  end

  after_validation do |attachment|
    # Replace 4 missing file errors with a unique, more descriptive error
    missing_file_errors = {
      "size"         => [ I18n.t('activerecord.errors.messages.blank'),
                          I18n.t('activerecord.errors.messages.inclusion') ],
      "content_type" => [ I18n.t('activerecord.errors.messages.blank') ],
      "filename"     => [ I18n.t('activerecord.errors.messages.blank') ]
    }

    found_errors = attachment.errors.select{ |k,v| v.all? { |msg| missing_file_errors[k.to_s].include?(msg) } }
    if found_errors.flatten.size >= 4
      errors = attachment.errors.clone
      attachment.errors.clear
      attachment.errors.add("upload_data",I18n.t('activerecord.errors.messages.missing'))
      errors.each do |att, msg|
        if missing_file_errors.has_key?(att.to_s)
          attachment.errors.add(att, msg) unless missing_file_errors[att.to_s].include?(msg)
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

    if attachment.agenda_entry   #if the attachment belongs to an agenda_entry, we create the hard link
      unless File.exist?("#{Rails.root.to_s}/attachments/conferences/#{attachment.event.permalink}/#{attachment.agenda_entry.title.gsub(" ","_")}/#{attachment.filename}")
        FileUtils.mkdir_p("#{Rails.root.to_s}/attachments/conferences/#{attachment.event.permalink}/#{attachment.agenda_entry.title.gsub(" ","_")}")
        FileUtils.ln(attachment.full_filename, "#{Rails.root.to_s}/attachments/conferences/#{attachment.event.permalink}/#{attachment.agenda_entry.title.gsub(" ","_")}/#{attachment.filename}")
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

    if attachment.agenda_entry   #if the attachment belongs to an agenda_entry, we delete the hard link
      if File.exist?("#{Rails.root.to_s}/attachments/conferences/#{attachment.event.permalink}/#{attachment.agenda_entry.title.gsub(" ","_")}/#{attachment.filename}")
        FileUtils.rm_rf("#{Rails.root.to_s}/attachments/conferences/#{attachment.event.permalink}/#{attachment.agenda_entry.title.gsub(" ","_")}/#{attachment.filename}")
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

  def current_data
    File.file?(full_filename) ? File.read(full_filename) : nil
  end

  def title
    filename
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

end
