module ActiveRecord #:nodoc:
  # Logoable ActiveRecord module
  module Logoable
    class << self
      def included(base) #:nodoc:
        base.extend ActsAsClassMethods
        base.send :include, ActsAsInstanceMethods
      end
    end

    module ActsAsClassMethods
      # Provides an ActiveRecord model with Logos
      #
      # Options:
      # class_name:: The model associated with this Logoable. Defaults to Logo.
      #
      def has_logo(options = {})
        ActiveRecord::Logoable.register_class(self)

        options[:class_name] ||= "Logo"

        has_one :logo, :as => :logoable,
                           :class_name => options[:class_name]

        send :attr_accessor, :_logo
        before_validation :_create_or_update_logo
        validates_associated :logo
        after_save :_save_logo!

        include InstanceMethods

        alias_method_chain :logo_image_path, :logo
      end

      alias_method :acts_as_logoable, :has_logo
    end

    # Methods related to Logo for all ActiveRecord instances
    module ActsAsInstanceMethods
      # The default path of logos for this instance
      #
      # Defaults to:
      #   public/images/models/:size/:logo_filename.png
      #
      def logo_image_path(options = {})
        options[:size] ||= 16

        "models/#{ options[:size] }/#{ logo_filename }.png"
      end

      # The default file name for an ActiveRecord instance.
      #
      # It is based on mime type or, if the object hasn't mime type, the class name tableized.
      #
      #   attachment.logo_file #=> "application-pdf.png"
      #   private_message.logo_file #=> "private_message.png"
      #
      def logo_filename
        respond_to?(:mime_type) && mime_type ?
          mime_type.to_s.gsub(/[\/\+]/, '-') : 
          self.class.to_s.underscore
      end
    end

    module InstanceMethods
      # alias_method_chain with logo support
      def logo_image_path_with_logo(options = {})
        logo.present? ?
          logo.logo_image_path(options) :
          logo_image_path_without_logo(options)
      end

      private

      def _create_or_update_logo #:nodoc:
        return unless @_logo.present? && @_logo[:media].present?

        logo ?
          logo.attributes = @_logo :
          build_logo(@_logo)
      end

      def _save_logo! #:nodoc:
        return unless logo && logo.changed?

        logo.logoable = self if logo.new_record?

        logo.save!

        @_logo = nil
      end
    end
  end
end
