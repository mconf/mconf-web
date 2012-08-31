# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'RMagick'

class EventLogo < Logo
  include Magick
  
  ASPECT_RATIO_S = "1/1"
  ASPECT_RATIO_F = 1
  
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
    errors.add(:base, "Aspect ratio invalid. Enable javascript to crop the image easily.") unless img.rows.to_f/img.columns.to_f ==  ASPECT_RATIO_F
  end
end
