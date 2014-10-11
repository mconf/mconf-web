# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class RegistrationsController < Devise::RegistrationsController
  layout 'no_sidebar'

  before_filter :check_registration_enabled, :only => [:new, :create]
  before_filter :configure_permitted_parameters, :only => [:create]

  def new
  end

  def edit
    redirect_to edit_user_path(current_user)
  end

  private

  def check_registration_enabled
    unless current_site.registration_enabled?
      flash[:error] = I18n.t("devise.registrations.not_enabled")
      redirect_to root_path
      false
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up).push(*allowed_params)
  end

  def allowed_params
    [:email, :_full_name, :username]
  end

  private

  # Redirect users to pretty page after registered and not approved
  def after_inactive_sign_up_path_for(resource)
    my_approval_pending_path
  end

end
