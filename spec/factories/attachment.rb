include ActionDispatch::TestProcess

Factory.define :attachment do |a|
  a.association :space
  a.association :author, :factory => :user
  a.uploaded_data { fixture_file_upload("#{ Rails.root.to_s }/public/images/vcc-logo.png", "image/png") }
end
