module Station #:nodoc:
  # Manage HTML documents
  class Html
    require 'hpricot'

    def initialize(text = "")
      @text = text
    end

    def doc
      @doc ||= Hpricot(@text)
    end

    def feeds
      doc.search('//link').select{ |l|
        l['rel'].match(/alternate/i)
      }
    end
  end
end
