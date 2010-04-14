module ConferenceManager
  class CmResource < ActiveResource::Base
    def self.domain
      Site.current.cm_domain.present? ? Site.current.cm_domain : "http://vcc.globalplaza.co.cc:8080"
    end
  end
end