# Require Station Model
require_dependency "#{ RAILS_ROOT }/vendor/plugins/station/app/models/logo"

class Logo
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
                    '16' => '16x16>',
                    'h64' => 'x64',
                    'front' => '188x143!'
                 }
end
