# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

module MyHelper

  def intervals(contents)
    today = {:contents => contents.select{|x| x.updated_at > Date.yesterday}, :name => t('today')}
    yesterday = {:contents => contents.select{|x| x.updated_at > Date.yesterday - 1 && x.updated_at < Date.yesterday}, :name => t('yesterday')}
    last_week = {:contents => contents.select{|x| x.updated_at > Date.today - 7 && x.updated_at < Date.yesterday - 1}, :name => t('last_week')}
    older = {:contents => contents.select{|x| x.updated_at < Date.today - 7}, :name => t('older')}

    [today, yesterday, last_week, older]
  end

  def home_menu_checkbox(name)
    check_box_tag name, name , @contents.map(&:to_s).include?(name), :class => 'home_menu_checkbox'
  end

  # Stores the current tab in the user's home menu
  def home_navbar_menu_at(tab)
    @home_navbar_menu_tab = tab
  end

  # Selects the tab if it is the current tab in the user's home menu
  def home_navbar_menu_select_if(tab, options={})
    old_class = options[:class] || ''
    @home_navbar_menu_tab == tab ?
    options.update({ :class => "#{old_class} active" }) :
      options
  end

end
