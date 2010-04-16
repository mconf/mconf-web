module ConferenceManager
  class Resource < ActiveResource::Base
    class << self
      def domain
        Site.current.cm_domain.present? ? Site.current.cm_domain : "http://vcc.globalplaza.co.cc:8080"
      end
      
      def subclasses
        @subclasses ||= []
      end
      
      def inherited subclass
        @subclasses = subclasses | Array(subclass)
        super
      end
      
      def reload
        subclasses.each{ |subclass|
          subclass.site = subclass.domain
        }
      end

      # redefine this two methods to remove .format extension
      def collection_path(prefix_options = {}, query_options = nil)
        prefix_options, query_options = split_options(prefix_options) if query_options.nil?
        "#{prefix(prefix_options)}#{collection_name}#{query_string(query_options)}"
      end
      
      
      def element_path(id, prefix_options = {}, query_options = nil)
        prefix_options, query_options = split_options(prefix_options) if query_options.nil?
        "#{prefix(prefix_options)}#{collection_name}/#{id}#{query_string(query_options)}"
      end
    end
  end
end
