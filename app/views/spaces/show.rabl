object @space => :space
attributes :slug, :name
node(:logo) do |space|
  { :width => 168, :height => 128, :logo_image_path => space.logo_image_url('logo168x128') }
end
node(:user_count) { |space| space.users.count }
