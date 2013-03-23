# -*- coding: utf-8 -*-
# Copyright 2008-2010 Universidad Politécnica de Madrid and Agora Systems S.A.
#
# This file is part of VCC (Virtual Conference Center).
#
# VCC is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# VCC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with VCC.  If not, see <http://www.gnu.org/licenses/>.

module LocaleControllerModule
  def set_current_locale
    I18n.locale = get_user_locale(current_user)
  end

  # Returns the locale that should be used for the user.
  def get_user_locale(user, use_session=true)

    # user locale
    if not user.nil? and user.is_a?(User) and
        user.locale.present? and locale_available?(user.locale)
      user.locale.to_sym

    # session locale
    elsif use_session and session[:locale] and locale_available?(session[:locale])
      session[:locale]

    # site locale
    elsif current_site and current_site.locale and locale_available?(current_site.locale)
      current_site.locale.to_sym

    # default locale - last fallback
    else
      I18n.default_locale
    end
  end

  # Returns true if the locale is available.
  def locale_available?(locale)
    I18n.available_locales.include?(locale.to_sym)
  end
end
