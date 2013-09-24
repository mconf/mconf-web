# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

module ModalsHelper

  # Creates a default close button to show in the header of modal windows
  def modal_close_button(options={})
    cls = 'close'
    options[:class] = options.has_key?(:class) ? "#{cls} #{options[:class]}" : cls
    options[:'data-dismiss'] = 'modal'
    content_tag :button, '&times;'.html_safe, options
  end

end
