class Attachment < ActiveRecord::Base
  has_attachment 
  belongs_to  :db_file

  validates_as_attachment

  alias_attribute :media, :uploaded_data
end
