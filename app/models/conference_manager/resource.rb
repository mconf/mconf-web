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
    end
  end
end