# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2017 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class SubscriptionsController < InheritedResources::Base

  load_and_authorize_resource
  layout :determine_layout

  def determine_layout
    if [:new].include?(action_name.to_sym) or [:create].include?(action_name.to_sym)
      "no_sidebar"
    else
      "application"
    end
  end


  def new
    if current_user.subscription.present?
      redirect_to user_subscription_path(current_user)
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
      redirect_to user_subscription_path(current_user), :flash => flash
    else
      flash = { error: t("subscriptions.failed") }
      redirect_to user_subscription_path(current_user), :flash => flash
    end
  end

  def show
    @subscription = User.find_by_username(params[:user_id]).subscription
    authorize! :show, (@subscription)
    # TODO: pagination stuff
  end

  def edit
    @subscription = User.find_by_username(params[:user_id]).subscription
    authorize! :edit, (@subscription)
  end

  def update
    @subscription = User.find_by_username(params[:user_id]).subscription
    authorize! :update, (@subscription)

    if @subscription.save
      flash = { success: t("subscriptions.created") }
      redirect_to user_subscription_path(current_user), :flash => flash
    else
      flash = { error: t("subscriptions.failed") }
      redirect_to user_subscription_path(current_user), :flash => flash
    end
  end

  def index
    paginate_subscriptions
    # TODO: pagination stuff
  end

  private

  def handle_access_denied exception
    if [:show, :index].include?(exception.action)
      flash = { error: t("subscriptions.denied") }
      redirect_to new_subscription_path, :flash => flash
    end
  end

  def paginate_subscriptions
    @subscriptions = @subscriptions.paginate(:page => params[:page], :per_page => 15)
  end


  allow_params_for :subscription
  def allowed_params
    [ :cpf_cnpj, :address, :additional_address_info,
      :number, :zipcode, :city, :province, :district, :country ]
  end

end
