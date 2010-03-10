module ActionView #:nodoc:
  module Helpers #:nodoc:
    module TagsHelper
      def tags(taggable)
        returning "" do |html|
          html << "<div id=\"#{ dom_id(taggable) }_tags\" class=\"tags\">"
          if taggable.tags.any?
            html << "<strong>#{ t('tag.other') }</strong>: "
            html << taggable.tags.map { |t| 
                     link_to(t.name, t, :rel => "tag") 
                    }.join(", ")
          end
          html << '</div>'
        end
      end

      # Draw the tag cloud of container.
      #
      # Only <a> links and ordered alphabetically
      #
      # Options:
      # count:: number of tags
      def tag_cloud(container, options = {})
        tags = container.tags.popular.all(options).sort{ |x, y| x.name <=> y.name }

        tags.any? ? render(:partial => 'tags/cloud', :object => tags) : ""
      end

      # Tag list for container <ul> ordered by popularity
      #
      # Options are passed like any ActiveRecord query
      #
      # Overwrite partial by placing your own in 'app/views/tags/list'
      def tag_list(container, options = {})
        tags = container.tags.popular.all(options)

        render(:partial => 'tags/list', :object => tags)
      end
    end
  end
end
