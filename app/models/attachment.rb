# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class Attachment < ActiveRecord::Base
  attr_accessor :post_title, :post_text

  has_many :post_attachments, :dependent => :destroy
  has_many :posts, :through => :post_attachments
  belongs_to :space
  belongs_to :author, :polymorphic => true

  mount_uploader :attachment, AttachmentUploader

  def post
    posts.first
  end

  def space
    space_id.present? ? Space.find_with_disabled(space_id) : nil
  end

  protected

  validate :validate_method
  def validate_method
    errors.add(:post_title, I18n.t('activerecord.errors.messages.blank')) if post_text.present? && post_title.blank?
  end

  before_save :update_attachment_attributes
  def update_attachment_attributes
    if attachment.present? && attachment_changed?
      self.content_type = attachment.file.content_type
      self.size = attachment.file.size
    end
  end

  public

  after_validation do |att|
    # Replace 4 missing file errors with a unique, more descriptive error
    missing_file_errors = {
      "size"         => [ I18n.t('activerecord.errors.messages.blank'),
                          I18n.t('activerecord.errors.messages.inclusion') ],
      "content_type" => [ I18n.t('activerecord.errors.messages.blank') ],
      "filename"     => [ I18n.t('activerecord.errors.messages.blank') ]
    }

    found_errors = att.errors.select{ |k,v| v.all? { |msg| missing_file_errors[k.to_s].include?(msg) } }
    if found_errors.flatten.size >= 4
      errors = att.errors.clone
      att.errors.clear
      att.errors.add("upload_data", I18n.t('activerecord.errors.messages.missing'))
      errors.each do |a, msg|
        if missing_file_errors.has_key?(a.to_s)
          att.errors.add(a, msg) unless missing_file_errors[a.to_s].include?(msg)
        end
      end
    end
  end

  after_save do |att|
    if att.post_title.present?
      p = Post.new(:title => att.post_title, :text => att.post_text)
      p.author = att.author
      p.space = att.space
      p.attachments << att
      p.save!

      att.post_title = att.post_text = nil
    end
  end

  after_destroy do |attachment|
    # no more versions
  end

  def current_data
    File.file?(full_filename) ? File.read(full_filename) : nil
  end

  def title
    attachment.file.identifier unless attachment.file.nil?
  end

  def full_filename
    attachment.file.file unless attachment.file.nil?
  end

  def self.repository_attachments(space, params)
    # params[:order], params[:direction]
    # put order back here
    attachments = space.attachments

    # Filter by attachment_ids
    if params[:attachment_ids].present?
      att_ids = params[:attachment_ids].split(",")
      attachments = attachments.where :id => att_ids
    end

    attachments.sort!{|x,y| x.author.name <=> y.author.name } if params[:order] == 'author' && params[:direction] == 'desc'
    attachments.sort!{|x,y| y.author.name <=> x.author.name } if params[:order] == 'author' && params[:direction] == 'asc'
    attachments.sort!{|x,y| x.content_type.split("/").last <=> y.content_type.split("/").last } if params[:order] == 'type' && params[:direction] == 'desc'
    attachments.sort!{|x,y| y.content_type.split("/").last <=> x.content_type.split("/").last } if params[:order] == 'type' && params[:direction] == 'asc'
    attachments.sort!{|x,y| x.created_at <=> y.created_at } if params[:order] == 'created_at' && params[:direction] == 'desc'
    attachments.sort!{|x,y| y.created_at <=> x.created_at } if params[:order] == 'created_at' && params[:direction] == 'asc'

    attachments
  end

end
