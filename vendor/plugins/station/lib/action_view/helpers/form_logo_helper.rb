module ActionView #:nodoc:
  module Helpers #:nodoc:
    # Provides methods for Logoable forms
    module FormLogoHelper
      # Render Logo file field and preview for Logoable models
      #
      # Object must be Logoable
      #
      # Options:
      # title:: Title of the form
      def logo_tag(object, options = {})
        InstanceTag.new(object, :logo, self, options.delete(:object)).to_logo_tag(options)
      end
    end

    class InstanceTag #:nodoc:
      include FormLogoHelper

      def to_logo_tag(options)
        options[:title] ||= I18n.t(:logo, :count => 1)

        # TODO
        # raise "#{ object } isn't Logoable" unless object.acts_as_logoable?

        @template_object.render :partial => "logoables/logo_tag", 
                                :locals => { :logoable => object,
                                             :logoable_name => object_name, 
                                             :title => options[:title] }
      end
    end

    class FormBuilder #:nodoc:
      def logo(options = {})
        @template.logo_tag(@object_name, options.merge(:object => @object))
      end
    end
  end
end
