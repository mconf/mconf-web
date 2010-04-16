module ConferenceManager
  class Streaming < Resource
    
    self.element_name = "streaming" 
    self.site = domain
    self.prefix = "/events/:event_id/"
    
    def html     
      "<embed name = '"+name+"' allowfullscreen= '"+allowfullscreen+"' src= '"+src+"' height='"+height+"' wmode='"+wmode+"' width='"+width+"'/>"
    end
  end
end
