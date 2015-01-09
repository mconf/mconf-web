# encoding: utf-8

class AttachmentUploader < CarrierWave::Uploader::Base
  # Choose what kind of storage to use for this uploader:
  storage :file

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "#{Rails.root}/private/uploads/space/attachment/#{model.id}"
  end

  def cache_dir
    "#{Rails.root}/private/tmp/uploads/cache/#{model.id}"
  end

  # Rename files when the name conflicts with another one in the same space
  def filename
    return if !original_filename.present?
    original_name = super

    tries = 1
    name = original_name
    while (att = model.space.attachments.find { |a| a.title == name && a != model })
      ext = File.extname(original_name)
      base = File.basename(original_name, ext)
      name = "#{base}_#{tries}#{ext}"
      tries += 1
    end

    name
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process :scale => [50, 50]
  # end

end
