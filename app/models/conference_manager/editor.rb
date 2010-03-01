module ConferenceManager
  class Editor < ActiveResource::Base
    self.element_name = "editor" 
    self.site = "http://vcc.globalplaza.co.cc:8080/events/:event_id"
    
    
    #redefined to remove format.extension
    def self.collection_path(prefix_options = {}, query_options = nil)
      prefix_options, query_options = split_options(prefix_options) if query_options.nil?
            "#{prefix(prefix_options)}#{collection_name}#{query_string(query_options)}"
    end
    
    
    def self.element_path(id, prefix_options = {}, query_options = nil)
    prefix_options, query_options = split_options(prefix_options) if query_options.nil?
           "#{prefix(prefix_options)}#{collection_name}/#{id}#{query_string(query_options)}"
    end
    
    
    def html     
      "<embed name = '"+name+"' allowfullscreen= '"+allowfullscreen+"' src= '"+src+"' height='"+height+"' wmode='"+wmode+"' width='"+width+"'/>"
    end
  end
end