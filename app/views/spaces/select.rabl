object @spaces => :spaces
attributes :id, :permalink, :name
node(:text) { |space| "#{space.name}" }