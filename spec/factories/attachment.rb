require 'action_controller/test_process'

Factory.define :attachment do |a|
  a.association :space
  a.association :author, :factory => :user
  a.uploaded_data { ActionController::TestUploadedFile.new "#{ RAILS_ROOT }/public/images/vcc-logo.png", "image/png" }
end
