# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2017 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class SubscriptionsController < InheritedResources::Base
  layout 'no_sidebar'
  load_and_authorize_resource

  def new
    if current_user.subscription.present?
      redirect_to user_subscriptions_path(current_user)
    end
  end

  def create
    free_days = Rails.application.config.trial_days

    @subscription.user_id = current_user.id
    # Will create it on IUGU for now
    @subscription.plan_id = Plan.find_by_ops_type("IUGU").id
    # Will create invoice for the 5th of the month when the trial expires
    @subscription.pay_day = (Date.today+free_days.days).strftime('%Y/%m/05')

    if @subscription.save
      flash = { success: t("subscriptions.created") }
      redirect_to my_home_path, :flash => flash
    else
      flash = { error: t("subscriptions.failed") }
      redirect_to my_home_path, :flash => flash
    end
  end

  def show
    redirect_to user_subscriptions_path(current_user)
    # TODO: pagination stuff
  end

  def index

  end

  private

  allow_params_for :subscription
  def allowed_params
    [ :cpf_cnpj, :address, :additional_address_info,
      :number, :zipcode, :city, :province, :district, :country ]
  end

end
