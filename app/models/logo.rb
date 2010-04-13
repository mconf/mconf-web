# Copyright 2008-2010 Universidad Politécnica de Madrid and Agora Systems S.A.
#
# This file is part of VCC (Virtual Conference Center).
#
# VCC is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# VCC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with VCC.  If not, see <http://www.gnu.org/licenses/>.

# Require Station Model
require_dependency "#{ RAILS_ROOT }/vendor/plugins/station/app/models/logo"
require 'RMagick'

class Logo
  include Magick
  
  ASPECT_RATIO_S = "188/143"
  ASPECT_RATIO_F = 188.0/143
  
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
                 
  #validate :aspect_ratio

  def aspect_ratio
    img = Magick::Image.read(temp_path).first
    errors.add_to_base("Aspect ratio invalid. Enable javascript to crop the image easily." ) unless (img.columns.to_f/img.rows.to_f*10).round ==  (ASPECT_RATIO_F*10).round
  end
  
end
