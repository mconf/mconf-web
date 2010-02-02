module ConferenceManager
  class CmEvent < ActiveResource::Base
    self.element_name = "event"
   # self.site="http://localhost:3010"
    self.site = "http://itecban2.dit.upm.es:8080"
    
    #redefined to remove format.extension
    def self.collection_path(prefix_options = {}, query_options = nil)
      prefix_options, query_options = split_options(prefix_options) if query_options.nil?
            "#{prefix(prefix_options)}#{collection_name}#{query_string(query_options)}"
    end
    
    
  end
end