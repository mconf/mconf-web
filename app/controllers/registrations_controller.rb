# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class RegistrationsController < Devise::RegistrationsController
  layout 'application'

  before_filter :check_registration_enabled, :only => [:new, :create]
  before_filter :configure_permitted_parameters, :only => [:create]
  before_filter only: [:create] do
    if verify_captcha == false
      flash[:error] = I18n.t('recaptcha.errors.verification_failed')

      # build the resource so we keep the information the user already filled
      # in the form
      build_resource(sign_up_params)
      render :new
    end
  end

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
    [ :locale, :email, profile_attributes: [ :full_name ] ]
  end

  private

  # Redirect users to pretty page after registered and not approved
  def after_inactive_sign_up_path_for(resource)
    my_approval_pending_path
  end

end
