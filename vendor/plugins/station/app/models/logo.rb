class Logo < ActiveRecord::Base
  has_attachment :max_size => 2.megabyte,
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
                 
  alias_attribute :media, :uploaded_data

  belongs_to :db_file
  belongs_to :logoable , :polymorphic => true

  validates_as_attachment

  acts_as_resource :disposition => :inline

  # Returns the image path for this resource
  def logo_image_path(options = {})
    respond_to?(:public_filename) ?
      public_filename(options[:size]) :
      [ self, { :format => self.format, :thumbnail => options[:size] } ]
  end
end
