# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

module Mconf

  # Module with utility methods to work with locales in a controller.
  # Included by ApplicationController mainly to get and set the locale of the user in the
  # session at each request.
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
      elsif session[:locale] and locale_available?(session[:locale])
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
      configatron.i18n.default_locales.include?(locale.to_sym)
    end
  end
end
