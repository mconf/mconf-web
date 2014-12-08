object @spaces => :spaces
attributes :id, :permalink, :name
node(:logo) do |space|
  { :width => nil, :height => nil, :logo_image_path => space.logo_image_url('logo168x128') }
end
node(:user_count) { |space| nil }
