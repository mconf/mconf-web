# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

module AtomHelper
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
            "#{current_site.domain_with_protocol }#{request.request_uri}"
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

    content_for :headers, "<link href=\"#{url}.atom\" rel=\"alternate\" title=\"#{title}\" type=\"application/atom+xml\" />".html_safe
  end
end
