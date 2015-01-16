# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class SitesController < ApplicationController
  before_filter :authenticate_user!
  authorize_resource :class => false
  layout "no_sidebar"

  def show
    @site = current_site
  end

  def edit
    @site = current_site
  end

  def update
    respond_to do |format|
      if current_site.update_attributes(site_params)
        flash[:success] = t('site.updated')
        format.html { redirect_to site_path }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  private

  allow_params_for :site
  def allowed_params
    [
     :name, :description, :domain, :locale, :timezone, :signature, :ssl, :feedback_url, :webconf_auto_record,
     :analytics_code, :shib_enabled, :shib_email_field, :shib_name_field, :shib_principal_name_field, :shib_login_field,
     :shib_env_variables, :shib_always_new_account, :ldap_enabled, :ldap_host, :ldap_port, :ldap_user, :ldap_user_password,
     :ldap_user_treebase, :ldap_username_field, :ldap_email_field, :ldap_name_field, :ldap_filter, :smtp_login, :smtp_password,
     :smtp_sender, :smtp_domain, :smtp_server, :smtp_port, :smtp_use_tls, :smtp_auto_tls, :smtp_auth_type, :exception_notifications,
     :exception_notifications_email, :exception_notifications_prefix, :chat_enabled, :presence_domain, :xmpp_server, :external_help,
     :registration_enabled, :require_registration_approval, :local_auth_enabled, :events_enabled
    ]
  end
end
