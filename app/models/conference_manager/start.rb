module ConferenceManager
  class Start < Resource
    singleton

    self.element_name = "start" 
    self.site = domain
    self.prefix = "/events/:event_id/"
  end   
end
