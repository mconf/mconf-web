# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class SessionLocalesController < ActionController::Base

  def create
    new_locale = params[:new_locale].to_sym

    if I18n.available_locales.include?(new_locale)
      # Add locale to the session
      session[:locale] =  new_locale
      # Add locale to the user profile
      current_user.update_attribute(:locale, new_locale) if user_signed_in?

      flash[:success] = t('locale.changed') + params[:new_locale]
    else
      flash[:error] = t('locale.error') + params[:new_locale]
    end

    redirect_to request.referer
  end

end
