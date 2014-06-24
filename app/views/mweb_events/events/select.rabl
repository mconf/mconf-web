object @events => :events
attributes :id, :permalink, :name, :public
node(:text) { |event| event.name }
node(:url) { |event| event_url(event) }
