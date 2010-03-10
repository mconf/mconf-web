module ActionView #:nodoc:
  module Helpers #:nodoc:
    module SourcesHelper
      # Return an Array of Sources from setup_source_uri
      #
      # If source has multiple feeds, it setups one source per feed.
      def setup_sources(source = Source.new)
        if source.errors.full_messages.include? I18n.t('source.errors.multiple_feeds')
          source.uri.html.feeds.map do |f|
            setup_source_attrs(Source.new(:target => source.target),
                               :uri   => f['href'],
                               :title => f['title'])
          end
        else
          Array(setup_source_attrs(source))
        end

      end

      # Fill Source attributes; source.title and source.uri with a new Uri instance
      def setup_source_attrs(source, attrs = {})
        returning source do |s|
          s.uri = Uri.new(:uri => attrs[:uri]) if s.uri.blank?
          s.title = attrs[:title] if s.title.blank?
        end
      end
    end
  end
end
