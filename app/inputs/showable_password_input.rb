# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# This is a custom input for SimpleForm.
# It displays a password in a form with a checkbox on its side to change the input to a text
# input (via javascript) and show the password.
# This shouldn't be used for real password, because even if the password is hidden in the interface,
# it can be seen in the HTML. But it's useful for relatively sensible data such as access keys.
class ShowablePasswordInput < SimpleForm::Inputs::StringInput
  include ActionView::Helpers::FormTagHelper

  def input(wrapper_options)
    options = merge_wrapper_options(input_html_options, wrapper_options)

    # set the value or the input will be empty, as is done by default for password inputs
    options[:value] = object.try(attribute_name)

    # the initial input is always a password input to hide the value
    options[:class] << :"form-control"
    field = @builder.password_field(attribute_name, options)

    ico1 = content_tag :i, nil, class: 'tooltipped fa fa-eye icon icon-show showable_password_show', title: I18n.t('_other.showable_password.show')
    ico2 = content_tag :i, nil, class: 'tooltipped fa fa-eye-slash icon icon-hide showable_password_hide', title: I18n.t('_other.showable_password.hide')
    content_tag(:div, "#{field}#{ico1}#{ico2}".html_safe)
  end
end
