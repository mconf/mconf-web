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

  # Handle errors - error pages
  rescue_from RestClient::Unauthorized, with: :ops_error

  layout "application"

  def find_subscription
    @subscription ||= User.find_by(username: params[:user_id]).try(:subscription)
    @subscription ||= Subscription.new(subscription_params)
  end

  def new
    @user = User.find_by(username: (params[:user_id]))
    if @user.subscription.present?
      redirect_to user_subscription_path(@user)
    end
  end

  def create
    @user = User.find_by(username: (params[:subscription][:user_id]))
    @subscription.setup(@user, Plan::OPS_TYPES[:iugu])

    if @subscription.save
      flash = { success: t("subscriptions.created") }
      redirect_to user_subscription_path(@user), :flash => flash
    else
      render new_user_subscription_path(@user)
    end
  end

  def show
    @user = User.find_by(username: (params[:user_id]))
    @invoices = @subscription.invoices.flatten
    @invoices.sort_by! { |invoice_date| invoice_date.due_date }.reverse!
  end

  def edit
    @user = User.find_by(username: (params[:user_id]))
  end

  def destroy
    if @subscription.destroy
      flash = { success: t("subscriptions.destroy") }
      redirect_to removed_subscription_path, :flash => flash
    else
      self.ops_error
    end
  end

  def update
    @user = User.find_by(username: (params[:user_id]))
    update! do |success, failure|
      success.html {
        flash[:notice] = t("subscriptions.update");
        redirect_to user_subscription_path(@user)
      }
      failure.html { render }
    end
  end

  def index
    paginate_subscriptions
    # TODO: pagination stuff
  end

  private

  def ops_error
    flash = { error: t("subscriptions.destroy_fail") }
    redirect_to user_subscription_path(@user), :flash => flash
  end

  def paginate_subscriptions
    unless @subscriptions.blank?
      @subscriptions = @subscriptions.paginate(:page => params[:page], :per_page => 15)
    end
  end


  allow_params_for :subscription
  def allowed_params
    [ :user_id, :cpf_cnpj, :address, :additional_address_info,
      :number, :zipcode, :city, :province, :district, :country ]
  end

end
