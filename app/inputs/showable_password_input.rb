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
    field = @builder.password_field(attribute_name, options)

    # add a checkbox
    cb_name = attribute_name.to_s + '_show'
    cb = check_box_tag cb_name, 'show', false, :class => 'showable_password_show'
    cb_label = label_tag cb_name, I18n.t('show_question'), :class => 'showable_password_show_label'

    # concat all inputs and labels
    "#{field}#{cb}#{cb_label}".html_safe
  end
end
