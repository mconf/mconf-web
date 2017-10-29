# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class DatetimePickerInput < SimpleForm::Inputs::StringInput
  include ActionView::Helpers::FormTagHelper

  def input(wrapper_options)
    options = merge_wrapper_options(input_html_options, wrapper_options)

    field = @builder.text_field(attribute_name, options)
    ico1 = content_tag :i, nil, class: 'tooltipped fa fa-calendar-o icon icon-date'
    content_tag :div, "#{field}#{ico1}".html_safe, class: 'datetime-picker-input'
  end
end
