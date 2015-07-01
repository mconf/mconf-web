# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class ConfirmationsController < Devise::ConfirmationsController
  layout 'no_sidebar'

  before_filter :check_registration_enabled, only: [:new, :create, :show]
  before_filter :check_already_confirmed, only: [:new, :create, :show]
  before_action :sanitize_parameters, only: [:create]

  protected

  def sanitize_parameters
    params[:user] = params[:user].permit(:unconfirmed_email, :email)
  end

  # Overriding devise's redirect path after confirmation instructions are sent
  def after_resending_confirmation_instructions_path_for(resource_name)
    if is_navigational_format?
      if user_signed_in?
        my_home_path
      else
        new_session_path(resource_name)
      end
    else
      '/'
    end
  end

  private

  def check_registration_enabled
    unless current_site.registration_enabled?
      raise ActionController::RoutingError.new('Not Found')
    else
      true
    end
  end

  def check_already_confirmed
    if user_signed_in? && current_user.confirmed?
      flash[:success] = t('confirmations.check_already_confirmed.already_confirmed')
      redirect_to my_home_path
    else
      true
    end
  end

end
