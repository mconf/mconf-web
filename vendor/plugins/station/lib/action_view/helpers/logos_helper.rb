module ActionView #:nodoc:
  module Helpers #:nodoc:
    module LogosHelper
      def logo_image_path(resource, options = {})
        options[:routing_type] = :path
        logo_image_url(resource, options)
      end

      # The url to the logo image for the resource.
      #
      # If the resource responds to logo_image_path method, take the arguments from it.
      #
      # Else, if the resource acts_as_logoable, returns the path for its Logo.
     #
      #
      # Finally, it looks for the image file in /public/images/models/:size/:mime-or-class.png
      #
      # Options:
      # routing_type:: The same as Rails polymorphic_url. When :path, it returns the relative path. When :url, the absolute url with host and protocol
      # size:: Size of the logo. Defaults to 16 pixels.

      def logo_image_url(resource, options = {})
        routing_type = options.delete(:routing_type) || :url
        options[:size] ||= 16

        args = resource.logo_image_path(options)

        case args
        when Array
          with_options :routing_type => routing_type do
            polymorphic_url *args
          end
        when String
          returning image_path(args) do |path|
            path.replace(request.protocol + request.host_with_port + path) if routing_type == :url
          end
        else
          raise "Invalid arguments from logo_image_path: #{ args.inspect }"
        end
      end

      # Prints an image_tag with the logo_image_path for the resource inside a div
      # Options:
      # title:: <tt>title</tt> attribute of the <tt>image_tag</tt>
      # alt:: <tt>alt</tt> attribute of the <tt>image_tag</tt>
      def logo(resource, options = {})
        options[:size] ||= 16
        url = options.delete(:url)
        alt = options.delete(:alt) || "[ #{ resource.respond_to?(:name) ? sanitize(resource.name) : resource.class } logo ]"
        title = options.delete(:title) || (resource.respond_to?(:title) ? sanitize(resource.title) : resource.class.to_s)

        returning "" do |html|
    #      html << "<div class=\"logo logo-#{ options[:size] }\">"

          image = image_tag(logo_image_path(resource, options),
                            :alt => alt,
                            :title => title,
                            :class => 'logo')

          html << link_to_if(url, image, url, :class => 'logo')

    #      html << '</div>'
        end
      end

      # The logotype is composed by the logo plus the name of the resource
      #
      # Uses the template in <tt>app/views/logoable/_logotype.html.erb</tt>
      #
      # Options:
      # spacer:: Separates logo and text
      # text:: Text besides the logo. Defaults to resource.name || resource.title || resource.class
      def logotype(resource, options = {})
        options[:spacer] ||= " "

        text = options.delete(:text) ||
          if resource.respond_to?(:name)
            sanitize resource.name
          elsif resource.respond_to?(:title)
            sanitize resource.title
          else
            t(:one, :scope => resource.class.to_s.underscore)
          end

        if options[:url]
          text = link_to(text, options[:url])
        end

        returning "" do |html|
          html << "<span id=\"#{ dom_id(resource) }-logotype\" class=\"logotype\">"
          html << logo(resource, options)
          html << options[:spacer]
          html << text
          html << '</span>'
        end
      end

      def try_url(resource) #:nodoc:
        polymorphic_path(resource)
      rescue NoMethodError
        nil
      end

      # Prints and links the resource logo.
      #
      # Options:
      # url:: The URL that will be used in the link. Defaults to the resource.
      def link_logo(resource, options = {})
        options[:url] ||= try_url(resource)
        logo(resource, options)
      end

      # Prints and links the resource logotype.
      #
      # Options:
      # url:: The URL that will be used in the link. Defaults to the resource.
      def link_logotype(resource, options = {})
        options[:url] ||= try_url(resource)
        logotype(resource, options)
      end

      # Prints link_logotype of the resource's author. If the resource hasn't author, uses Anonymous user.
      def link_author(resource, options = {})
        author = resource.respond_to?(:author) && resource.author ?
                   resource.author :
                   Anonymous.current
        link_logotype(author, options)
      end

      # Show a preview of content if it's not null and it isn't a new record. 
      # Preview consists of link_logo to the content
      def preview(content, options = {})
        return "" unless content && ! content.new_record?

        options[:size] ||= 64
        options[:text] ||= t(:current, :scope => content.class.to_s.underscore)

        link_logotype(content, options)
      end
    end
  end
end
