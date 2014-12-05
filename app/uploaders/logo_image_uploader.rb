# encoding: utf-8
require 'carrierwave/processing/mini_magick'

class LogoImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

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

  # Create different versions of your uploaded files:
  version :large do
    resize_to_limit(350,350)
  end

  version :logo32 do
    process :crop
    process :resize_and_extend => [32, 32]
  end

  version :logo84x64 do
    process :crop
    process :resize_and_extend => [84, 64]
  end

  version :logo128 do
    process :crop
    process :resize_and_extend => [128,128]
  end

  version :logo168x128 do
    process :crop
    process :resize_and_extend => [168, 128]
  end

  def crop
    if model.crop_x.present?
      resize_to_limit(350,350)
      manipulate! do |img|
        x = model.crop_x
        y = model.crop_y
        w = model.crop_w
        h = model.crop_h

        img.crop("#{w}x#{h}+#{x}+#{y}")
        img
      end
    end
  end

end
