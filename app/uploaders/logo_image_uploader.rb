# encoding: utf-8

class LogoImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick

  storage :file

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_white_list
    %w(jpg jpeg png svg tif gif)
  end

  # Create different versions of your uploaded files:
  version :large do
    resize_to_limit(350,350)
  end

  version :logo32 do
    process :crop
    resize_to_fill(32,32)
  end

  version :logo84x64 do
    process :crop
    resize_to_fill(84,64)
  end

  version :logo128 do
    process :crop
    resize_to_fill(128,128)
  end

  version :logo168x128 do
    process :crop
    resize_to_fill(168,128)
  end

  def crop
    if model.crop_x.present?
      resize_to_limit(350, 350)
      manipulate! do |img|
        x = model.crop_x.to_i
        y = model.crop_y.to_i
        w = model.crop_w.to_i
        h = model.crop_h.to_i
        img.crop!(x, y, w, h)
      end
    end
  end

end
