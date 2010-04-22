module ConferenceManager
  class Editor < Resource
    singleton

    self.element_name = "editor" 
    self.site = domain
    self.prefix = "/events/:event_id/" 

    def html
      tag = attributes.inject(""){ |tag, at|
              tag << "#{ at.first }=\"#{ at.last }\" "
            }

      "<embed #{ tag }/>"
    end
  end
end
