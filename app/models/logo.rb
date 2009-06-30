# Require Station Model
require_dependency "#{ RAILS_ROOT }/vendor/plugins/station/app/models/logo"
require 'RMagick'

class Logo
  include Magick
  
  ASPECT_RATIO_S = "188/143"
  ASPECT_RATIO_F = 188/143.to_f
  
  
  has_attachment :max_size => 2.megabyte,
                 :storage => :file_system,
                 :content_type => :image,
                 :thumbnails => {
                    'w256' => '256x',
                    'h256' => 'x256',
                    'w128' => '128x',
                    'h128' => 'x128',
                    'w96' => '96x',
                    'h96' => 'x96',
                    'w72' => '72x',
                    'h72' => 'x72',
                    'w64' => '64x',
                    'h64' => 'x64',
                    'w48' => '48x',
                    'h48' => 'x48',
                    'w32' => '32x',
                    'h32' => 'x32',
                    'w22' => '22x',
                    'h22' => 'x22',
                    'w16' => '16x',
                    'h16' => 'x16',
                    'front' => '188x143!'
                 }
                 
  validate :aspect_ratio

  def aspect_ratio
    img = Magick::Image.read(temp_path).first
    errors.add_to_base("Aspect ratio invalid. Enable javascript to crop the image easily." ) unless (img.columns.to_f/img.rows.to_f*10).round ==  (ASPECT_RATIO_F*10).round
  end
  
end
