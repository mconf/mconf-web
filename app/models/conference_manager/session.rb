module ConferenceManager
  class Session < CmResource
    self.element_name = "session" 
    self.site = domain + "/events/:event_id"
    
    
    #redefined to remove format.extension
    def self.collection_path(prefix_options = {}, query_options = nil)
      prefix_options, query_options = split_options(prefix_options) if query_options.nil?
            "#{prefix(prefix_options)}#{collection_name}#{query_string(query_options)}"
    end
    
    
    def self.element_path(id, prefix_options = {}, query_options = nil)
    prefix_options, query_options = split_options(prefix_options) if query_options.nil?
           "#{prefix(prefix_options)}#{collection_name}/#{id}#{query_string(query_options)}"
    end
    
    
    def recording?
      recording == "true"
    end  
    
    
    def streaming?
      streaming == "true"
    end
  end
end