# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "uri"
require "net/http"

class LdapController < ApplicationController

  respond_to :html
  layout false

  # Log in a user using his ldap information
  # The application should only reach this point after authenticating using Ldap
  # The authentication is currently made with the devise strategie ldap_authenticatable
  def create
#    test_data()
    unless current_site.ldap_enabled?
      redirect_to login_path
      return
    end
    
    #stores any "Ldap-" variable in the session
#    ldap_vars_to_session()
    ldap_data = {}
    request.env.each do |key, value|
      ldap_data[key] = value if key.to_s.downcase =~ /^ldap-/
    end
    session[:ldap_data] = ldap_data

    # the fields that define the name and email are configurable in the Site model
    ldap_name = request.env[current_site.ldap_name_field] || request.env["Ldap-uid"]
    ldap_email = request.env[current_site.ldap_email_field] || request.env["Ldap-mail"]

    # uses the fed email to check if the user already has an account
    user = User.find_by_email(ldap_email)

    # the user already has an account but it was not activated yet
    if user and !user.active?
      @user = user
      render "need_activation"
      return
    end

    # the fed user has no account yet
    # create one based on the info returned by ldap_authenticatable
    if user.nil?
      password = SecureRandom.hex(16)
      user = User.create!(:username => ldap_name.clone, :email => ldap_email,
                          :password => password, :password_confirmation => password)
      user.activate
      user.profile.update_attributes(:full_name => ldap_name)
      flash[:notice] = t('ldap.create.account_created', :url => new_user_password_path)
    end

    # login and go to home
    sign_in user, :bypass => true
    redirect_to home_path
  end

#AUXILIARY FUNCTIONS#####################################################################
  def info
    @data = session[:ldap_data] if session.has_key?(:ldap_data)
  end

  # Stores any ldap variable in the session
  # Uses the variables defined in Site#ldap_env_variables if any,
  # otherwise use all variables that start with "ldap-".
  # Comparisons are case-insensitive and trimmed.
  def ldap_vars_to_session
    unless current_site.ldap_env_variables.blank?
      vars = current_site.ldap_env_variables
      vars = vars.split(/\r?\n/).map{ |s| s.strip().downcase() }
      filter = vars.map{ |v| /^#{v}$/  }
    else
      filter = /^ldap-/
    end

    ldap_data = {}
    #for each environment variable
    request.env.each do |key, value|
      if filter.is_a?(Regexp)
        ldap_data[key] = value if key.to_s.downcase =~ /^ldap-/
      else
        unless filter.select{ |f| key.to_s.downcase =~ f }.empty?
          ldap_data[key] = value
        end
      end
    end
    logger.info "Ldap: saving variables to session #{ldap_data.inspect}, filter #{filter.inspect}"
    session[:ldap_data] = ldap_data
    ldap_data
  end

  # Searches for a LdapToken using data in the session. 
  # Creates a new LdapToken if nothing is found.
  def find_or_create_token
    email = ldap_email_from_session()
    token = LdapToken.find_by_identifier(email)
    token = create_token(email) if token.nil?
    token
  end

  def create_token(id)
    LdapToken.create!(:identifier => id)
  end

  # Checks if the required information for ldap to work is available in the session.
  def check_ldap_information
    unless session[:ldap_data] &&
        ldap_email_from_session() &&
        ldap_name_from_session()
      logger.info "Ldap: failed to find ldap information in the session, " +
        "data: #{session[:ldap_data].inspect}"
      flash[:error] = t("ldap.create.data_error")
      render 'error', :layout => 'application_without_sidebar'
      false
    else
      true
    end
  end

  # Checks if ldap is enabled in the current site.
  def check_ldap_enabled
    unless current_site.ldap_enabled
      logger.info "Ldap: tried to access but shibboleth is disabled"
      redirect_to login_path
      return false
    else
      return true
    end
  end

  # If there's a current user redirects to home.
  def check_current_user
    if current_user != Anonymous.current
      redirect_to home_path
      return false
    else
      return true
    end
  end

  # Returns the ldap user email from the data stored in the session.
  def ldap_email_from_session
    email = nil
    if session[:ldap_data]
      email   = session[:ldap_data][current_site.ldap_email_field]
      email ||= session[:ldap_data]["ldap-inetOrgPerson-mail"]
    end
    logger.info "Ldap: couldn't get email from session, " +
      "trying field #{current_site.ldap_email_field} " +
      "in #{session[:ldap_data].inspect}" if email.nil?
    email
  end

  # Returns the ldap user name from the data stored in the session.
  def ldap_name_from_session
    name = nil
    if session[:ldap_data]
      name   = session[:ldap_data][current_site.ldap_name_field]
      name ||= session[:ldap_data]["ldap-inetOrgPerson-cn"]
    end
    logger.info "Ldap: couldn't get name from session, " +
      "trying field #{current_site.ldap_name_field} " +
      "in #{session[:ldap_data].inspect}" if name.nil?
    name
  end

  def test_data
    # FAKE TEST DATA
    request.env["ldap-Application-ID"] = "default"
    request.env["ldap-Session-ID"] = "09a612f952cds995e4a86ddd87fd9f2a"
    request.env["ldap-Identity-Provider"] = "https://login.somewhere/idp/shibboleth"
    request.env["ldap-Authentication-Instant"] = "2011-09-21T19:11:58.039Z"
    request.env["ldap-Authentication-Method"] = "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport"
    request.env["ldap-AuthnContext-Class"] = "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport"
    request.env["ldap-brEduPerson-brEduAffiliationType"] = "student;position;faculty"
    request.env["ldap-eduPerson-eduPersonPrincipalName"] = "75a988943825d2871e1cfa75473ec0@ufrgs.br"
    request.env["ldap-inetOrgPerson-cn"] = "Rick Astley"
    request.env["ldap-inetOrgPerson-sn"] = "Rick Astley"
    request.env["ldap-inetOrgPerson-mail"] = "nevergonnagiveyouup@rick.com"
    request.env["cn"] = "Haddaway"
    request.env["sn"] = "Haddaway"
    request.env["mail"] = "whatislove@haddaway.com"
    request.env["uid"] = "teste123"
  end

end
