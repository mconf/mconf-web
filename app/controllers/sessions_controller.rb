# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class SessionsController < Devise::SessionsController
  layout 'application'

  # To allow other applications to sign in users in Mconf-Web
  skip_before_filter :verify_authenticity_token, :only => [:create]

  # If there's no auth enabled, go to the frontpage and not the login page
  before_filter only: [:new, :create] do

    # when going through the admin login page we allow access
    matcher = /^#{Regexp.escape(admin_login_path)}$/
    if !request.path.match(matcher)

      site = Site.current
      if !site.local_auth_enabled? && !site.ldap_enabled?
        redirect_to root_path
      end

    end
  end
end
