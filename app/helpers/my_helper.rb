# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
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

end
