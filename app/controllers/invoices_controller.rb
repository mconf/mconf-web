# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2017 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class InvoicesController < InheritedResources::Base
  before_filter :authenticate_user!

  before_filter :find_invoice
  authorize_resource :invoice, :through => :user, :singleton => true

  layout :determine_layout

  def determine_layout
    if [:new, :create].include?(action_name.to_sym)
      "no_sidebar"
    else
      "application"
    end
  end

  def find_invoice
    @invoice ||= Invoice.find_by(id: params[:id])
  end

  def show
    @user = User.find_by(username: (params[:user_id]))
    @invoice = @user.subscription.invoices.find_by(id: (params[:id]))
  end

  def index
    @user = User.find_by(username: (params[:user_id]))
    @invoices = @user.subscription.invoices
  end

  def report
    @user = User.find_by(username: (params[:user_id]))
    @invoice ||= Invoice.find_by(id: params[:id])

    if File.exists?(@invoice.report_file_path)
      @file = @invoice.report_file_path
      send_file @file, disposition: 'attachment', x_sendfile: true
    else
      flash = { error: t(".report_missing") }
      redirect_to user_invoice_path(@user, @invoice.id), :flash => flash
    end
  end
end
