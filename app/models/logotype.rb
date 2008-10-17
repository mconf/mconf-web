class Logotype < ActiveRecord::Base
  acts_as_content :has_media => :attachment_fu
  has_attachment :max_size => 1.megabyte,
                 :content_type => :image, 
                 :thumbnails => { :space => '200x200>' , :photo => '180x180>'},
                 :resize_to => '300x300>'
                 
  alias_attribute :media, :uploaded_data
  belongs_to :db_file
  belongs_to :logotypable , :polymorphic =>true
  validates_as_attachment
end
