# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

module Mconf

  # A module to control guest access to the website.
  # A guest is a user that is authenticated somehow but doesn't have an account.
  # Their information is stored in a cookie with a short expiration time.
  module GuestUserModule
    # the name of the cookie
    COOKIE_KEY = :_mconf_guest

    # how long the cookie will last (in seconds)
    COOKIE_DURATION = 3600 # 1h

    def guest_user_signed_in?
      cookies.encrypted[Mconf::GuestUserModule::COOKIE_KEY].present?
    end

    def current_guest_user
      cookie = cookies.encrypted[Mconf::GuestUserModule::COOKIE_KEY]
      if cookie.present?
        @user ||= User.new
        @user.email = cookie[:email]
        @user.username = cookie[:name].parameterize
        @user.profile.full_name = cookie[:name]
        @user
      else
        nil
      end
    end

    def sign_in_guest(name, email, expires=nil)
      expires ||= Time.now + COOKIE_DURATION
      cookies.encrypted[Mconf::GuestUserModule::COOKIE_KEY] = {
        value: {
          name: name,
          email: email
        },
        expires: expires
      }
    end

    def logout_guest
      cookies.delete(COOKIE_KEY)
    end

    # Controller action to sign out a guest user
    def logout_guest_action
      logout_guest
      redirect_to user_return_to
    end

  end

end
