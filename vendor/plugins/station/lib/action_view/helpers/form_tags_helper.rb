module ActionView #:nodoc:
  module Helpers # :nodoc:
    # Provides methods for Taggable forms
    module FormTagsHelper
      # Render text field for assigning Tags to object.
      #
      # Object must be Taggable
      #
      def tags_text_field_tag(object, options = {})
        InstanceTag.new(object, :tags, self, options.delete(:object)).to_tags_text_field_tag(options)
      end

      def tags_select_tag(object, options = {})
        InstanceTag.new(object, :tags, self, options.delete(:object)).to_tags_select_tag(options)
      end
    end

    class InstanceTag #:nodoc:
      include FormTagsHelper

      def to_tags_text_field_tag(options)
        # TODO
        # raise "#{ object } isn't Taggable" unless object.acts_as_taggable?

        @template_object.render :partial => "taggables/tags_text_field_tag", 
                                :locals => { :taggable => object,
                                             :taggable_name => object_name }
      end

      def to_tags_select_tag(options)
        # TODO
        # raise "#{ object } isn't Taggable" unless object.acts_as_taggable?

        @template_object.render :partial => "taggables/tags_select_tag", 
                                :locals => { :taggable => object,
                                             :taggable_name => object_name }
      end

    end

    class FormBuilder #:nodoc:
      def tags_text_field(options = {})
        @template.tags_text_field_tag(@object_name, options.merge(:object => @object))
      end

      def tags_select(options = {})
        @template.tags_select_tag(@object_name, options.merge(:object => @object))
      end
    end
  end
end
