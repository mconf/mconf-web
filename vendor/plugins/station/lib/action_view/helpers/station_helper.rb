# Basic Helper Methods
module ActionView #:nodoc:
  module Helpers #:nodoc:
    module StationHelper
      # Get title in this order:
      # 1. string argument 
      # 2. Title based on variables set by the Controller
      # 3. <tt>controller.controller_name</tt> - <tt>current_site.name</tt>
      #
      # Options:
      # <tt>append_site_name</tt>:: Append the Site name to the title, ie, "Title - Example Site". Defaults to <tt>false</tt>
      #
      def title(*args)
        options = args.extract_options!

        title = if args.first.present?
                  args.first
                elsif @resources # Use instance. Don't call the method and query database
                  path_container ?
                    t(:other_in_container, :scope => controller.controller_name.singularize, :container => path_container.name) :
                    t(:other, :scope => controller.controller_name.singularize)
                elsif @resource # Use instance. Don't call the method and query database
                  if @resource.new_record?
                    t(:new, :scope => @resource.class.to_s.underscore)
                  elsif controller.action_name == 'edit' || @resource.errors.any?
                    t(:editing, :scope => @resource.class.to_s.underscore)
                  else
                    @resource.respond_to?(:title) ? @resource.title : "#{ @resource.class.to_s } #{ @resource.id }"
                  end
                else
                  controller.controller_name.titleize
                end.dup

        title << " - #{ current_site.name }" if options[:append_site_name]
                
        sanitize(title)
      end

      # Renders notification_area div if there is a flash entry for types: 
      # <tt>:valid</tt>, <tt>:error</tt>, <tt>:warning</tt>, <tt>:info</tt>, <tt>:notice</tt> and <tt>:success</tt>
      def notification_area
        returning '<div id="notification_area">' do |html|
          for type in %w{ valid error warning info notice success}
            next if flash[type.to_sym].blank?
            html << "<div class=\"#{ type }\">#{ flash[type.to_sym] }</div>"
          end
          html << "</div>"
        end 
      end

      # Prints an atom <tt>link</tt> header for feed autodiscovery.
      # Use it in partials:
      #   atom_link
      # will link to current request_uri + .atom
      #
      # You can pass url arguments
      #   atom_link(current_container, Content.new)
      #
      # You must have <tt>yield(:headers)</tt> in your layout for using this helper method
      def atom_link_header(*args)
        options = ( args.last.is_a?(Hash) ? args.pop : Hash.new )

        url = case args.size
              when 0
                # Without arguments, link to current request uri
                "#{ current_site.domain_with_protocol }#{ request.request_uri }"
              when 1
                case args.first
                when String
                  args.first
                else
                  polymorphic_url(args)
                end
              else
                polymorphic_url(args)
              end
        
        title = options[:title] || self.title

        content_for :headers, "<link href=\"#{ url }.atom\" rel=\"alternate\" title=\"#{ title }\" type=\"application/atom+xml\" />"
      end
    end
  end
end

