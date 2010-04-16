module ConferenceManager
  class PlayerSession < Resource
   
    self.element_name = "player_session" 
    self.site = domain
    self.prefix = "/events/:event_id/sessions/:session_id/" 
    
    def html     
      "<embed name = '"+name+"' allowfullscreen= '"+allowfullscreen+"' src= '"+src+"' height='"+height+"' wmode='"+wmode+"' width='"+width+"'/>"
    end
  end
end
