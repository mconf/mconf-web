# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class SitesController < ApplicationController
  before_filter :authenticate_user!
  authorize_resource class: false
  layout "manage"

  def show
    redirect_to edit_site_path
  end

  def edit
    @site = current_site
  end

  def update
    @site = current_site

    # For some reason the form always adds an empty option to this
    # array, so we have to remove it
    if params[:site] && params[:site].key?(:visible_locales)
      params[:site][:visible_locales] = params[:site][:visible_locales].reject(&:blank?)
    end

    respond_to do |format|
      if @site.update_attributes(site_params)
        flash[:success] = t('site.updated')
        format.html { redirect_to edit_site_path }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  private

  allow_params_for :site
  def allowed_params
    [
     :name, :description, :domain, :locale, :timezone, :signature, :ssl, :feedback_url,
     :analytics_code, :shib_enabled, :shib_email_field, :shib_name_field, :shib_principal_name_field, :shib_login_field,
     :shib_env_variables, :shib_always_new_account, :ldap_enabled, :ldap_host, :ldap_port, :ldap_user, :ldap_user_password,
     :ldap_user_treebase, :ldap_username_field, :ldap_email_field, :ldap_name_field, :ldap_filter, :smtp_login, :smtp_password,
     :smtp_sender, :smtp_receiver, :smtp_domain, :smtp_server, :smtp_port, :smtp_use_tls, :smtp_auto_tls, :smtp_auth_type, :exception_notifications,
     :exception_notifications_email, :exception_notifications_prefix, :external_help,
     :registration_enabled, :require_registration_approval, :local_auth_enabled, :spaces_enabled, :activities_enabled,
     :room_dial_number_pattern, :shib_update_users, :require_space_approval, :forbid_user_space_creation, :max_upload_size, :use_gravatar,
     :captcha_enabled, :recaptcha_public_key, :recaptcha_private_key, :unauth_access_to_conferences,
     :certificate_login_enabled, :certificate_id_field, :certificate_name_field,
     #:events_enabled,
     visible_locales: []
    ]
  end
end
