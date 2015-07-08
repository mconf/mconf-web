# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

module PrivateMessagesHelper

  # Stores the current tab in the menu
  def private_messages_menu_at(tab)
    @private_messages_menu_tab = tab
  end

  # Selects the tab if it is the current tab in the menu
  def private_messages_menu_select_if(tab, options={})
    old_class = options[:class] || ''
    @private_messages_menu_tab == tab ?
      options.update({ :class => "#{old_class} selected" }) :
      options
  end

end
