class PostAttachment < ActiveRecord::Base
  belongs_to :post
  belongs_to :attachment  
end