object @spaces => :spaces
attributes :id, :permalink, :name, :public
node(:text) { |space| space.name }
node(:url) { |space| space_url(space) }
