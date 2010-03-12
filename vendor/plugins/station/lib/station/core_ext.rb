Object.class_eval do
  def __station_deprecate_method__(old_method, new_method)
    module_eval <<-END_METHOD
      def #{ old_method } *args
        logger.debug "Station: DEPRECATION WARNING \\"#{ old_method }\\". Please use \\"#{ new_method }\\" instead."
        line = caller.select{ |l| l =~ /^\#{ RAILS_ROOT }/ }.first
        logger.debug "           in: \#{ line }"
        send :#{ new_method }, *args
      end
      END_METHOD
  end
end

unless Symbol.instance_methods.include? 'to_class'
  Symbol.class_eval do
    def to_class
      self.to_s.classify.constantize
    end
  end
end

unless ActionController::PolymorphicRoutes.respond_to?(:polymorphic_url_with_container)
  ActionController::PolymorphicRoutes.module_eval do
    def polymorphic_url_with_container(record_or_hash_or_array, options = {})
      if options.delete(:container) == false
        return polymorphic_url_without_container(record_or_hash_or_array, options)
      end

      rha_with_container =
        case record_or_hash_or_array
        when Array
          unshift_container record_or_hash_or_array.dup
        when Hash
          record_or_hash_or_array.dup
        else
          unshift_container [ record_or_hash_or_array ]
        end

      polymorphic_url_without_container(rha_with_container, options)
    end
    alias_method_chain :polymorphic_url, :container

    def unshift_container(array)
      if array.size == 1 && array.first.respond_to?(:container)
        array.unshift(array.first.container)
      else
        array
      end
    end
  end
end

unless ActionView::Helpers::AtomFeedHelper.respond_to?(:atom_entry)
  ActionView::Helpers::AtomFeedHelper.module_eval do
    # Helper function for describing Atom Service documents. See RFC 5023
    #
    # Default XML namespace is 'http://www.w3.org/2007/app'
    # 'atom' namespace corresponds to 'http://www.w3.org/2005/Atom',
    #
    def atom_service(record, current_agent, options = {}, &block)
      xml = options[:xml] || eval("xml", block.binding)
      xml.instruct!

      xml.service "xmlns" => "http://www.w3.org/2007/app", "xmlns:atom" => 'http://www.w3.org/2005/Atom' do
      # Workspaces are Containers current_agent can post to:
      record.stages.select{ |s| s.authorize?(:read, :to => current_agent) }.each do |container|
        xml.workspace do
          xml.tag!( "atom:title", container.name )
            if container.authorize?([ :read, :Content ], :to => current_agent)
              # Collections are different type of Contents
              for content in container.accepted_content_types
                xml.collection(:href => polymorphic_path([ container, content.to_class.new ]) + '.atom') do
                  xml.tag!("atom:title", I18n.t('other_in_container', :container => container.name, :scope => content.to_class.to_s.underscore))
                  xml.accept(container.authorize?([ :create, :Content ], :to => current_agent) ? content.to_class.accepts : nil)
                end
              end
            end
          end
        end
      end
    end

    # Helper function for describing Atom Entry documents. See RFC 5023
    #
    # Default XML namespace is 'http://www.w3.org/2005/Atom',
    # 'app' namespace corresponds to 'http://www.w3.org/2007/app'
    #
    def atom_entry(record, options = {}, &block)
      if options[:schema_date]
        options[:schema_date] = options[:schema_date].strftime("%Y-%m-%d") if options[:schema_date].respond_to?(:strftime)
      else
        options[:schema_date] = "2005" # The Atom spec copyright date
      end

      xml = options[:xml] || eval("xml", block.binding)
      xml.instruct!

      entry_opts = { "xml:lang" => options[:language] || "en-US",
                      "xmlns" => 'http://www.w3.org/2005/Atom',
                      "xmlns:app" => 'http://www.w3.org/2007/app'
      }
      entry_opts.merge!(options).reject!{|k,v| !k.to_s.match(/^xml/)}

      xml.entry(entry_opts) do
        xml.id("tag:#{request.host},#{options[:schema_date]}:#{record.class}/#{record.id}")

        if options[:published] || (record.respond_to?(:created_at) && record.created_at)
          xml.published((options[:published] || record.created_at).xmlschema)
        end

        if options[:updated] || (record.respond_to?(:updated_at) && record.updated_at)
          xml.updated((options[:updated] || record.updated_at).xmlschema)
        end

        xml.link(:rel => 'alternate', :type => 'text/html', :href => options[:root_url] || polymorphic_url(record))
        xml.link(:rel => 'self', :type => 'application/atom+xml', :href => options[:url] || request.url)

        yield ActionView::Helpers::AtomFeedHelper::AtomFeedBuilder.new(xml, self, options)
      end
    end
  end
end

require 'will_paginate'

module WillPaginate::ViewHelpers #:nodoc:
  def will_paginate_with_translation(collection = nil, options = {})
    options[:previous_label] ||= I18n.t('pagination.previous_label')
    options[:next_label] ||= I18n.t('pagination.next_label')

    will_paginate_without_translation(collection, options)
  end

  alias_method_chain :will_paginate, :translation
end

# atom-tools like interface for standard Ruby RSS library
begin
  require 'rss/1.0'
  require 'rss/2.0'

  # AtomTools compatibility with Ruby RSS standard lib
  module RSS::AtomTools #:nodoc:
    module Feed
      def entries
        items
      end

      def title
        if @channel
          Atom::Text.new @channel.title
        else
          nil
        end
      end
    end

    module Entry
      def id
        respond_to?(:guid) && guid.present? ? guid.content : nil
      end

      def content
        return @content if @content

        @content = Atom::Text.new description
        @content.type = 'html'
        @content
      end

      def links
        return [] unless @link

        Array(Atom::Link.new :type => 'text/html', :rel => 'alternate', :href => @link)
      end

      def updated
        # Get rid of bug: https://rails.lighthouseapp.com/projects/8994/tickets/1701-argumenterror-in-time_with_zonerb146
        respond_to?(:pubDate) ? Time.parse(pubDate.to_s) : Time.now
      end

      def published
        # Get rid of bug: https://rails.lighthouseapp.com/projects/8994/tickets/1701-argumenterror-in-time_with_zonerb146
        respond_to?(:pubDate) ? Time.parse(pubDate.to_s) : Time.now
      end
    end
  end

  class RSS::Rss #:nodoc:
    include RSS::AtomTools::Feed
  end

  class RSS::RDF #:nodoc:
    include RSS::AtomTools::Feed
  end

  class RSS::Rss::Channel::Item #:nodoc:
    include RSS::AtomTools::Entry
  end

  class RSS::RDF::Item #:nodoc:
    include RSS::AtomTools::Entry
  end
rescue => e
  puts "Station Warning: RSS library missing"
  puts e
end

