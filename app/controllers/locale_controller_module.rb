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
  def set_vcc_locale
    if logged_in? && current_user.is_a?(User) && current_user.locale.present? && I18n.available_locales.include?(current_user.locale.to_sym)
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
