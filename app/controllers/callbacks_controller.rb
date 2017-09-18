# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2017 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class CallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    login_or_create_from_provider("Google")
  end

  def facebook
    login_or_create_from_provider("facebook")
  end

  def login_or_create_from_provider(provider)
    @user = User.from_omniauth(request.env['omniauth.auth'])
    if @user.persisted?
      flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: provider
      sign_in_and_redirect @user, event: :authentication
    else
      session["devise.#{provider.parameterize}_data"] = request.env['omniauth.auth'].except(:extra)
      redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
    end
  end
end