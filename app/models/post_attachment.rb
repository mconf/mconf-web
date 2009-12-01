class PostAttachment < ActiveRecord::Base
  belongs_to :post
  belongs_to :attachment
  
  named_scope :version, lambda { |v|
    { :conditions => {:attachment_version => v} }
  }
  
end