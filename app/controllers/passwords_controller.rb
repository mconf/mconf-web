# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class PasswordsController < Devise::PasswordsController
  layout 'no_sidebar'

  before_filter :check_only_local_authentication, :only => [:new]
  before_filter :sanitize_parameters, only: [:create]

  def reset_email
    @email = params[:email]
  end

  protected

  def after_sending_reset_password_instructions_path_for(resource_name)
    reset_email_path(email: resource_params[:email])
  end

  private

  def sanitize_parameters
    params[:user] = params[:user].permit(:unconfirmed_email, :email)
  end

  def check_only_local_authentication
    unless current_site.local_auth_enabled?
      raise ActionController::RoutingError.new('Not Found')
    else
      true
    end
  end

end
