require 'active_resource/formats/html_format'

module ConferenceManager
  class Streaming < Resource
    singleton
    
    self.element_name = "streaming" 
    self.site = domain
    self.prefix = "/events/:event_id/"
    self.format = :html

  end
end
