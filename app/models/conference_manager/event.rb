module ConferenceManager
  class Event < CmResource
    self.element_name = "event"
    self.site = domain
    
    
    #redefined to remove format.extension
    def self.collection_path(prefix_options = {}, query_options = nil)
      prefix_options, query_options = split_options(prefix_options) if query_options.nil?
            "#{prefix(prefix_options)}#{collection_name}#{query_string(query_options)}"
    end
    
    
    def self.element_path(id, prefix_options = {}, query_options = nil)
    prefix_options, query_options = split_options(prefix_options) if query_options.nil?
           "#{prefix(prefix_options)}#{collection_name}/#{id}#{query_string(query_options)}"
      end
    
    
    def enable_sip?
      enable_sip == "true"
    end
    
    
    def enable_isabel?
      enable_isabel == "true"
    end
    
    
    def enable_web?
      enable_web =="true"
    end
    
  end
end