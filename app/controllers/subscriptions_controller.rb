# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2017 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class SubscriptionsController < InheritedResources::Base

  before_filter :authenticate_user!

  before_filter :find_subscription
  authorize_resource :subscription, through: :user, singleton: true

  layout :determine_layout

  def find_subscription
    @subscription ||= User.find_by(username: params[:user_id]).try(:subscription)
    @subscription ||= Subscription.new(subscription_params)
  end

  def determine_layout
    if [:new, :create].include?(action_name.to_sym)
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
    @subscription.setup(current_user, Plan::OPS_TYPES[:iugu])

    if @subscription.save
      flash = { success: t("subscriptions.created") }
      redirect_to user_subscription_path(current_user), :flash => flash
    else
      render new_subscription_path
    end
  end

  def show
  end

  def edit
  end

  def destroy
    if @subscription.destroy
      flash = { success: t("subscriptions.destroy") }
      redirect_to my_home_path, :flash => flash
    end
  end

  def update
    update! do |success, failure|
      success.html {
        flash[:notice] = t("subscriptions.update");
        redirect_to user_subscription_path(current_user)
      }
      failure.html { render }
    end
  end

  def index
    paginate_subscriptions
    # TODO: pagination stuff
  end

  private

  def paginate_subscriptions
    @subscriptions = @subscriptions.paginate(:page => params[:page], :per_page => 15)
  end


  allow_params_for :subscription
  def allowed_params
    [ :cpf_cnpj, :address, :additional_address_info,
      :number, :zipcode, :city, :province, :district, :country ]
  end

end
