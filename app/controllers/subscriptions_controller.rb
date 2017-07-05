# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2017 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class SubscriptionsController < InheritedResources::Base
  layout 'no_sidebar'
  load_and_authorize_resource

  #before_filter :check_subscription_enabled, :only => [:new, :create]
  #before_filter :configure_permitted_parameters, :only => [:create]
  #before_filter :check_terms_acceptance, :only => [:create]
  def new
  end

  def index
    redirect_to user_subscriptions_path(current_user)
  end

  private

#  def check_subscription_enabled
#    unless current_site.subscription_enabled?
#      flash[:error] = I18n.t("devise.subscription.not_enabled")
#      redirect_to root_path
#      false
#    end
#  end

#  def configure_permitted_parameters
#    devise_parameter_sanitizer.for(:subscription).push(*allowed_params)
#  end

#  def check_terms_acceptance
#    unless ActiveRecord::ConnectionAdapters::Column.value_to_boolean(params[:terms])
#      flash[:error] = I18n.t("devise.subscription.terms_reject")
#      build_resource(sign_up_params)
#      render :new
#    end
#  end

  def allowed_params
    [ :locale, :email, :username,
      profile_attributes: [ :address, :city, :province, :country, :zipcode, :phone,
                            :full_name, :organization, :description, :url,
                            :cpf_cnpj, :service_usage_select, :service_usage ]
    ]
  end

end
