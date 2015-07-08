# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# encoding: utf-8
require 'carrierwave/processing/mini_magick'

class LogoImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  MAX_WIDTH = 350
  MAX_HEIGHT = 350

  storage :file

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_white_list
    %w(jpg jpeg png svg tif gif)
  end

  def resize_and_extend w, h
    manipulate! do |img|
      img.resize "#{w}x#{h}"
      img.background 'white'
      img.gravity 'center'
      img.extent "#{w}x#{h}"
      img
    end
  end

  # The original image but restricted to a maximum size
  version :large do
    process :crop
    resize_to_limit(MAX_WIDTH, MAX_HEIGHT)
  end

  # Small user avatar
  version :logo32 do
    process :crop
    process :resize_and_extend => [32, 32]
  end

  # Medium user avatar
  version :logo128 do
    process :crop
    process :resize_and_extend => [128, 128]
  end

  # Large user avatar
  version :logo300 do
    process :crop
    process :resize_and_extend => [300, 300]
  end

  # Small space logo
  version :logo84x64 do
    process :crop
    process :resize_and_extend => [84, 64]
  end

  # Medium space logo
  version :logo168x128 do
    process :crop
    process :resize_and_extend => [168, 128]
  end

  # Large space logo
  version :logo336x256 do
    process :crop
    process :resize_and_extend => [310, 236]
  end

  def crop
    if model.crop_x.present?
      resize_to_limit(MAX_WIDTH, MAX_HEIGHT)
      manipulate! do |img|
        # TODO: What if img here is not the same size as the one
        #   displayed while cropping? It doesn't happen today, but might
        #   happen soon (e.g. cropping imgs in smaller screens). Should consider
        #   the size of `img` here too.
        x = (model.crop_x.to_f * model.crop_img_w.to_f).to_i
        y = (model.crop_y.to_f * model.crop_img_h.to_f).to_i
        w = (model.crop_w.to_f * model.crop_img_w.to_f).to_i
        h = (model.crop_h.to_f * model.crop_img_h.to_f).to_i
        img.crop("#{w}x#{h}+#{x}+#{y}")
        img
      end
    end
  end

end
