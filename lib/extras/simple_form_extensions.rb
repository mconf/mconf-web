# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# From:
# https://github.com/plataformatec/simple_form/wiki/Twitter-Bootstrap-v2-and-simple_form-v2
module WrappedButton
  def wrapped_button(*args, &block)
    options = args.extract_options!
    wrapper_class = ['form-actions', options[:wrapper_class]].compact
    options.delete(:wrapper_class)
    template.content_tag :div, :class => wrapper_class do
      loading = !self.object or self.object.new_record? ? I18n.t('simple_form.creating') : I18n.t('simple_form.updating')
      options[:"data-loading-text"] = [loading, options[:"data-loading-text"]].compact
      options[:class] = ["btn", 'btn-primary', options[:class]].compact
      args << options
      if cancel = options.delete(:cancel)
        submit(*args, &block) + ' ' + I18n.t('simple_form.buttons.or') + ' ' + template.link_to(I18n.t('simple_form.buttons.cancel'), cancel)
      elsif cancel = options.delete(:cancel_modal)
        submit(*args, &block) + ' ' + I18n.t('simple_form.buttons.or') + ' ' + template.link_to(I18n.t('simple_form.buttons.cancel'), '#', :'data-dismiss' => 'modal')
      else
        submit(*args, &block)
      end
    end
  end
end
SimpleForm::FormBuilder.send :include, WrappedButton
