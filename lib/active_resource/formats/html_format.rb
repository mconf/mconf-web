# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

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
