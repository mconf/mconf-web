class News < ActiveRecord::Base
  belongs_to :space
  
  validates_presence_of :title, :text, :space_id
end
