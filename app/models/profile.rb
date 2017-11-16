# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class Profile < ActiveRecord::Base

  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h, :crop_img_w, :crop_img_h
  mount_uploader :logo_image, LogoImageUploader

  # BigbluebuttonRoom requires an identifier with 3 chars generated from :name
  # So we'll require :full_name to have length >= 3
  validates :full_name, presence: true, length: { minimum: 3 }, on: :create
  alias_attribute :name, :full_name

  after_update :crop_avatar

  def crop_avatar
    logo_image.recreate_versions! if crop_x.present?
  end

  after_update :update_webconf_room

  def update_webconf_room
    if self.full_name_changed? && self.user.bigbluebutton_room
      if self.full_name_was == self.user.bigbluebutton_room.name
        params = { name: self.full_name }
        self.user.bigbluebutton_room.update_attributes(params)
      end
    end
  end

  belongs_to :user

  # The order implies inclusion: everybody > members > public_fellows > private_fellows
  VISIBILITY = [:everybody, :members, :public_fellows, :private_fellows, :nobody]

  validates :full_name, presence: true

  def linkable_url
    unless url.blank?
      if url.match(/http[s]?:\/\//)
        url
      else
        "http://#{url}"
      end
    end
  end

  # Returns the user's first name(s) making sure it is at least `min_length` characters
  # long. Might return a string with more than a word.
  def first_name(min_length = 4)
    unless self.full_name.blank?
      # parse_name(self.full_name)[:first_name]
      names = self.full_name.split(' ')
      names.inject('') do |memo, name|
        if memo.blank?
          name
        elsif memo.length < min_length
          "#{memo} #{name}"
        else
          memo
        end
      end
    end
  end

  def small_logo_image?
    logo_image.height < 100 || logo_image.width < 100
  end

  def valid_url?
    uri = URI.parse(self.url)
    !uri.host.nil?
  rescue URI::InvalidURIError
    false
  end
end
