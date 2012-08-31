# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

module LocaleControllerModule
  def set_vcc_locale
    if user_signed_in? && current_user.is_a?(User) && current_user.locale.present? && I18n.available_locales.include?(current_user.locale.to_sym)
      I18n.locale = current_user.locale.to_sym
    elsif session[:locale] and I18n.available_locales.include?(session[:locale])
      I18n.locale = session[:locale]
    elsif current_site and current_site.locale and I18n.available_locales.include?(current_site.locale.to_sym)
      I18n.locale = current_site.locale
    else
      I18n.locale = I18n.default_locale
    end
  end
end
