# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

module ThemesHelper

  def theme_name
    Rails.application.config.theme.try(:strip)
  end

  def theme_class
    "theme-#{theme_name}" unless theme_name.blank?
  end

  def theme_favico
    if theme_name.blank?
      favicon_link_tag
    else
      favicon_link_tag("favico-#{theme_name}.ico")
    end
  end

end
