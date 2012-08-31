# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class ShowablePasswordInput < SimpleForm::Inputs::PasswordInput
  include ActionView::Helpers::FormTagHelper

  def input
    field = @builder.password_field(attribute_name, input_html_options)
    cb_name = attribute_name.to_s + '_show'
    cb = check_box_tag cb_name, 'show', false, :class => 'showable_password_show'
    cb_label = label_tag cb_name, I18n.t('show_question'), :class => 'showable_password_show_label'
    "#{field}#{cb}#{cb_label}".html_safe
  end
end
