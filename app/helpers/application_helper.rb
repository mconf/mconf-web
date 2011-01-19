# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def menu(tab)
    @menu_tab = tab
  end

  def menu_options(tab, options = {})
    @menu_tab == tab ?
      options.update({ :class => 'selected' }) :
      options
  end
 
  def options_for_select_with_class_selected(container, selected = nil)
    container = container.to_a if Hash === container
    selected, disabled = extract_selected_and_disabled(selected)

    options_for_select = container.inject([]) do |options, element|
      text, value = option_text_and_value(element)
      selected_attribute = ' selected="selected" class="selected"' if option_value_selected?(value, selected)
      disabled_attribute = ' disabled="disabled"' if disabled && option_value_selected?(value, disabled)
      options << %(<option value="#{html_escape(value.to_s)}"#{selected_attribute}#{disabled_attribute}>#{html_escape(text.to_s)}</option>)
    end
 
    options_for_select.join("\n")
  end

  # Initialize an object for a form with suitable params
  def prepare_for_form(obj, options = {})
    case obj
    when Post
      #obj.attachments.build
      obj.attachments << Attachment.new if obj.new_record? && obj.attachments.blank? 

      obj.space = @space if obj.space.blank?
    when Attachment    
      obj.space = @space if obj.space.blank?
    when AgendaEntry
       obj.attachments << Attachment.new if obj.new_record? && obj.attachments.blank?
       obj.attachment_video ||= AttachmentVideo.new  
    else
      raise "Unknown object #{ obj.class }"
    end

    options.each_pair do |method, value|  # Set additional attributes like:
      obj.__send__ "#{ method }=", value         # post.event = @event
    end

    obj
  end  
  
  def generate_html(form_builder, method, options = {})
    options[:object] ||= form_builder.object.class.reflect_on_association(method).klass.new
    options[:partial] ||= method.to_s.singularize
    options[:form_builder_local] ||= :f

    form_builder.fields_for(method, options[:object], :child_index => 'NEW_RECORD') do |f|
      locals = { options[:form_builder_local] => f }
      render(:partial => options[:partial], :locals => locals)
    end
  end

  def generate_template(form_builder, method, options = {})
    escape_javascript generate_html(form_builder, method, options)
  end 
  
  
#  def t(key, options = {})
#    I18n.t(key, options) + link_to("T", :action => 'index', :controller => 'translate',
#                                        :key_type => 'starts_with',
#                                        :key_pattern => key.downcase,
#                                        :from_locale => I18n.locale,
#                                        :to_locale => I18n.locale)
#  end

end
