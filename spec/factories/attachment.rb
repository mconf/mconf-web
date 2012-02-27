include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :attachment do |a|
    a.association :space
    a.association :author, :factory => :user
    a.uploaded_data { fixture_file_upload "#{PathHelpers.assets_full_path}/images/vcc-logo.png", "image/png" }
  end
end
