module ConferenceManager
  class Player < Resource
    
    self.element_name = "player" 
    self.site = domain 
    self.prefix = "/events/:event_id/"
    
    def html     
      "<embed name = '"+name+"' allowfullscreen= '"+allowfullscreen+"' src= '"+src+"' height='"+height+"' wmode='"+wmode+"' width='"+width+"'/>"
    end
  end
end
