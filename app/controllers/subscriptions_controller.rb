# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2017 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class SubscriptionsController < InheritedResources::Base
  layout 'no_sidebar'
  load_and_authorize_resource

  free_days = Rails.application.config.trial_days

  #before_filter :check_subscription_enabled, :only => [:new, :create]
  #before_filter :check_terms_acceptance, :only => [:create]
  def new
    if current_user.subscription.present?
      redirect_to user_subscriptions_path(current_user)
    end
  end

  def create
    puts params["subscription"]["user"]["profile"]
    #current_user.profile.update_attributes(params["subscription"]["user"]["profile"])

    @subscription.user_id = current_user.id
    # Will create it on IUGU for now
    @subscription.plan_id = Plan.find_by_ops_type("IUGU").id
    # Will create invoice for the 5th of the month when the trial expires
    @subscription.pay_day = (Date.today+free_days.days).strftime('%Y/%m/05')
  end

  def index
    redirect_to user_subscriptions_path(current_user)
    # TODO: pagination stuff
  end

  private

#  def check_subscription_enabled
#    unless current_site.subscription_enabled?
#      flash[:error] = I18n.t("devise.subscription.not_enabled")
#      redirect_to root_path
#      false
#    end
#  end

#  def check_terms_acceptance
#    unless ActiveRecord::ConnectionAdapters::Column.value_to_boolean(params[:terms])
#      flash[:error] = I18n.t("devise.subscription.terms_reject")
#      build_resource(sign_up_params)
#      render :new
#    end
#  end

  allow_params_for :subscription
  def allowed_params
    [ user: [ profile: [ :address, :city, :province, :country, :zipcode, :phone,
                            :organization, :cpf_cnpj ] ]
    ]
  end

end
