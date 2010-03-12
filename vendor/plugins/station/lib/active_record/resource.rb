module ActiveRecord #:nodoc:
  # == acts_as_resource
  # Station goes one step further the Rails scaffold.
  #
  # A Resource is a model that supports, at least, CRUD operations. 
  # As consecuence, it can be imported/exported in several Content Types, which include:
  #
  # XML:: text document encoded using Extensible Markup Language (XML). These include XHTML, Atom and RSS.
  # YAML:: text document encoded using YAML Ain't a Markup Language (YAML). These include JSON.
  # HTML encoding:: usually the result of HTML Forms, uses application/x-www-form-urlencoded or multipart/form-data
  # Raw:: binary data
  #
  # Include this functionality in your models using ActsAsMethods#acts_as_resource
  module Resource
    class << self
      # Return the first Resource class supporting this Content Type
      def class_supporting(content_type)
        mime_type = content_type.is_a?(Mime::Type) ?
          content_type :
          Mime::Type.lookup(content_type)
        
        classes.each do |klass|
          return klass if klass.mime_types.include?(mime_type)
        end
        nil
      end

      def included(base) # :nodoc:
        # Fake named_scope to ActiveRecord instances that haven't children
        base.named_scope :roots, lambda  { {} } unless base.respond_to?(:roots)
        base.extend ActsAsMethods
      end
    end

    module ActsAsMethods
      # Provides an ActiveRecord model with Resource capabilities
      #
      # Options:
      # * <tt>:mime_types</tt> - array of Mime::Type supported by this Resource.
      # * <tt>:has_media</tt> - this Content has attachment data. Supported plugins: AttachmentFu (<tt>:attachment_fu</tt>)
      # * <tt>:param</tt> - used to find and build the URLs. Defaults to <tt>:id</tt>
      # * <tt>:disposition</tt> - specifies whether the Resource will be shown inline or as attachment (see Rails send_file method). Defaults to :attachment
      # * <tt>:per_page</tt> - number of Resources shown per page, using will_pagination plugin. Defaults to 9
      # * <tt>:delegate_content_types</tt> - allow using ActiveRecord::Resource.class_supporting for finding the class most suitable for some media. This is useful if you have a generic model for Attachments, but specific files like images or audios should be managed by other classes. Defaults to <tt>false</tt>
      #
      def acts_as_resource(options = {})
        ActiveRecord::Resource.register_class(self)

        options[:param]       ||= :id
        options[:disposition] ||= :attachment
        options[:per_page]    ||= 9
        options[:delegate_content_types] ||= false

        named_scope :roots, lambda {
          column_names.include?('parent_id') ?
          { :conditions => { :parent_id => nil } } :
          {}
        }

        if options[:has_media] == :attachment_fu
          alias_attribute :media, :uploaded_data
        end

        unless acts_as?(:agent)
          attr_protected :author, :author_id, :author_type
        end

        cattr_reader :resource_options
        class_variable_set "@@resource_options", options

        cattr_reader :per_page
        class_variable_set "@@per_page", options[:per_page]

        if SourceImportation.table_exists?
          has_one :source_importation, :as => :importation, :dependent => :destroy
        end

        acts_as_sortable

        extend  ClassMethods
        include InstanceMethods

        alias_method_chain :logo_image_path, :thumbnails
      end

      # Find with params
      def find_with_param(*args)
        if respond_to?(:resource_options)
          send "find_by_#{ resource_options[:param] }", *args
        else
          find *args
        end
      end
    end

    module ClassMethods
      # Array of Mime objects accepted by this Content
      def mime_types
        Array(resource_options[:mime_types]).map{ |m| Mime.const_get(m.to_sym.to_s.upcase) }
      end

      def atom_parser(data)
        begin
          require 'atom/entry'
        rescue
          raise "Station: You need 'atom-tools' gem for AtomPub support"
        end

        unless respond_to?(:params_from_atom)
          raise "Station: You must implement #{ self.to_s }#params_from_atom method to parse Atom entries"
        end

        params_from_atom Atom::Entry.new(data)
      end

      # Create a new instance of this Resource from Atom Entry
      def from_atom(entry)
        self.new(params_from_atom(entry))
      end

      # List of comma separated content types accepted for this Content
      def accepts
        list = mime_types.map{ |m| Array(m.to_s) + m.instance_variable_get("@synonyms") }.flatten
        list << "application/atom+xml;type=entry" if self.respond_to?(:params_from_atom)
        list.uniq.join(", ")
      end
    end

    module InstanceMethods
      # Returns the mime type for this Content instance. 
      # Example: Mime::XML
      def mime_type
        return nil unless respond_to?(:content_type)

        mime_type = Mime::Type.lookup(content_type)
        # mime_type must be a registered Mime::Type
        mime_type.instance_variable_get("@symbol") ?
          mime_type :
          nil
      end

      # Returns the Mime::Type symbol for this content
      def format
        mime_type ? mime_type.to_sym : nil
      end
      
      # Method useful for icon files
      #
      # If the Content has a Mime Type, return it scaped with '-' 
      #   application/jpg => application-jpg
      # else, return the underscored class name:
      #   photo
      def mime_type_or_class_name
        mime_type ? mime_type.to_s.gsub(/[\/\+]/, '-') : self.class.to_s.underscore
      end

      # Define to_param method with acts_as_resource param option
      def to_param
        send(self.class.resource_options[:param]).to_s
      end

      # Update attributes from Atom Entry or Source entry
      #
      # You must implement params_from_atom class method
      def from_atom(entry)
        unless self.class.respond_to?(:params_from_atom)
          raise "Station: You must implement #{ self.to_s }#params_from_atom method to parse Atom entries"
        end

        self.attributes = self.class.params_from_atom(entry)

        if respond_to?(:created_at)
          self.created_at = Time.parse(entry.published.to_s)
        end

        if respond_to?(:updated_at)
          self.updated_at = Time.parse(entry.updated.to_s)
        end

        if respond_to?(:author)
          # TODO: find by OpenID or other attributes
          self.author = Anonymous.current
        end

        self
      end

      # Update attributes using params_from_atom and save the Resource
      #
      # Saves the record without timestamps, so created_at and updated_at are the original from the feed entry
      def from_atom!(entry)
        freezing_timestamps do
          from_atom(entry)
          save!
        end

        self
      end

      # The arguments to polymorphic_path to build the path for this resource Logo
      def logo_image_path_with_thumbnails(options = {})
        options[:size] ||= 16

        thumbnail_logo_image?(options) ?
          [ self, { :format => format, :thumbnail => options[:size] } ] :
          logo_image_path_without_thumbnails(options)
      end

      private

      # Is there a logo_image_path available?
      def thumbnail_logo_image?(options)
        # FIXME: this is only for AttachmentFu
        ! new_record? &&
          respond_to?(:attachment_options) &&
          attachment_options[:thumbnails].keys.map(&:to_s).include?(options[:size].to_s) &&
          thumbnails.find_by_thumbnail(options[:size].to_s).present?
      end

      def freezing_timestamps
        class_timestamps_cache = self.class.record_timestamps
        self.class.record_timestamps = false
        yield
        self.class.record_timestamps = class_timestamps_cache
      end
    end
  end
end
