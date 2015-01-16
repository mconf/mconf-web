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
      current_site ||= Site.current

      # user locale
      if user_has_locale?(user)
        user.locale.to_sym

      # session locale
      elsif use_session and session_has_locale?(session)
        session[:locale]

      # site locale
      elsif site_has_locale?(current_site)
        current_site.locale.to_sym

      # default locale - last fallback
      else
        I18n.default_locale
      end
    end

    # Returns whether the user has a locale set and valid.
    def user_has_locale?(user)
      !user.nil? && user.is_a?(User) &&
        user.locale.present? && locale_available?(user.locale)
    end

    # Returns whether the session has a locale set and valid.
    def session_has_locale?(session)
      !session.nil? && session[:locale] && locale_available?(session[:locale])
    end

    def site_has_locale?(site)
      site && site.locale && locale_available?(site.locale)
    end

    # Returns true if the locale is available.
    def locale_available?(locale)
      I18n.locale_available? locale
    end
  end
end
