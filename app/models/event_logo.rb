require 'RMagick'

class EventLogo < Logo
  include Magick
  
  ASPECT_RATIO = "1/1"
  
  has_attachment :max_size => 2.megabyte,
                 :storage => :file_system,
                 :content_type => :image,
                 :thumbnails => {
                   '256' => '256x256>',
                   '128' => '128x128>',
                   '96' => '96x96>',
                   '72' => '72x72>',
                   '64' => '64x64>',
                   '48' => '48x48>',
                   '32' => '32x32>',
                   '22' => '22x22>',
                   '16' => '16x16>'
                 }
                 
  validate :aspect_ratio

  def aspect_ratio
    img = Magick::Image.read(temp_path).first
    errors.add_to_base("Aspect ratio invalid. Enable javascript to crop the image easily.") unless img.rows.to_f/img.columns.to_f ==  ASPECT_RATIO.to_f
  end
end
