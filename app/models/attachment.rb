# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class Attachment < ActiveRecord::Base
  include PublicActivity::Model

  tracked owner: :space,
    recipient: -> (ctrl, model) { model.try(:author) },
    params: {
      username: -> (ctrl, model) { model.try(:author).try(:name) },
      trackable_name: -> (ctrl, model) { model.title }
    }

  belongs_to :space
  belongs_to :author, :polymorphic => true

  mount_uploader :attachment, AttachmentUploader

  before_save :update_attachment_attributes

  def space
    Space.with_disabled.where(:id => space_id).first
  end

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

  def title
    attachment.file.identifier unless attachment.file.nil?
  end

  def full_filename
    attachment.file.file unless attachment.file.nil?
  end

  def self.repository_attachments(space, params)
    attachments = space.attachments

    # Filter by attachment_ids
    if params[:attachment_ids].present?
      att_ids = params[:attachment_ids].split(",")
      attachments = attachments.where :id => att_ids
    end

    attachments
  end

  protected

  # Adds the content_type and size attributes to the attachment
  def update_attachment_attributes
    if attachment.present? && attachment_changed?
      self.content_type = attachment.file.content_type
      self.size = attachment.file.size
    end
  end

end
