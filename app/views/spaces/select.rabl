object @spaces => :spaces
attributes :id, :permalink, :name, :public
node(:text) { |space| html_escape(space.name) }
node(:url) { |space| space_url(space) }
