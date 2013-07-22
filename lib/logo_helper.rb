module LogoHelper

  def resize path, size
    f = File.open(path)
    img = Magick::Image.read(f).first
    if img.columns > img.rows && img.columns > size
      resized = img.resize(size.to_f/img.columns.to_f)
      f.close
      resized.write("png:" + path)
    elsif img.rows > img.columns && img.rows > size
      resized = img.resize(size.to_f/img.rows.to_f)
      f.close
      resized.write("png:" + path)
    end
  end

  def update_logo
    return unless @default_logo.present?

    img_orig = Magick::Image.read(File.join(PathHelpers.images_full_path, @default_logo)).first
    img_orig = img_orig.scale(337, 256)
    images_path = PathHelpers.images_full_path
    final_path = FileUtils.mkdir_p(File.join(images_path, "tmp/#{@rand_value}"))
    img_orig.write(File.join(images_path, "tmp/#{@rand_value}/temp.jpg"))
    original = File.open(File.join(images_path, "tmp/#{@rand_value}/temp.jpg"))

    original_tmp = Tempfile.new("default_logo", "#{Rails.root.to_s}/tmp/")
    original_tmp_io = open(original_tmp)
    original_tmp_io.write(original.read)
    filename = File.join(images_path, @default_logo)
    (class << original_tmp_io; self; end;).class_eval do
      define_method(:original_filename) { filename.split('/').last }
      define_method(:content_type) { 'image/jpeg' }
      define_method(:size) { File.size(filename) }
    end

    logo = { :media => original_tmp_io }
    logo = self.build_logo(logo)

    images_path = PathHelpers.images_full_path
    tmp_path = File.join(images_path, "tmp")

    if @rand_value != nil
      final_path = FileUtils.rm_rf(tmp_path + "/#{@rand_value}")
    end
  end

end