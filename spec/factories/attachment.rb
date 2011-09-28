Factory.define :attachment do |a|
  a.association :space
  a.association :author, :factory => :user
  a.attachment(:uploaded_data, "public/images/vcc-logo.png", "image/png")
end
