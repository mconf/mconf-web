module ActiveResource
  module Formats
    module HtmlFormat
      extend self

      def extension
        "html"
      end

      def mime_type
        "text/html"
      end

      def encode(hash, options = nil)
        ""
      end

      def decode(html)
        { :html => html }
      end
    end
  end
end
