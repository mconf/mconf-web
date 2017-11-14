object @events => :events
attributes :id, :slug, :public
node(:name) { |event| html_escape(event.name) }
node(:text) { |event| html_escape(event.name) }
node(:url) { |event| event_url(event) }
