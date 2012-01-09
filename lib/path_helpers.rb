class PathHelpers

  def self.images_full_path
    File.join(Rails.root.to_s, "app", "assets", "images")
  end

  def self.assets_full_path
    File.join(Rails.root.to_s, "app", "assets")
  end

end
