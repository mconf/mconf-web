# -*- coding: utf-8 -*-
# Copyright 2008-2010 Universidad Politécnica de Madrid and Agora Systems S.A.
#
# This file is part of VCC (Virtual Conference Center).
#
# VCC is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# VCC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with VCC.  If not, see <http://www.gnu.org/licenses/>.

require "uri"
require "net/http"

class ShibbolethController < ApplicationController

  respond_to :html
  layout 'application_without_sidebar'

  before_filter :check_shib_enabled
  before_filter :check_current_user, :except => [:info]

  # Log in a user using his shibboleth information
  # The application should only reach this point after authenticating using Shibboleth
  # The authentication is currently made with the Apache module mod_shib
  def login
    shib_vars_to_session()
    return unless check_shib_information()

    token = find_or_create_token()

    # no user associated yet, render a page to do it
    if token.user.nil?
      logger.info "Shibboleth: first access for this user, go to association page"
      respond_to do |format|
        format.html
      end

    # everything's ok, log in
    else
      logger.info "Shibboleth: user logged in #{token.user.inspect}"
      self.current_agent = token.user
      flash.keep(:success)
      redirect_to home_path
    end
  end

  # Associates the current shib user with an existing user or
  # a new user account (created here as well).
  def associate
    # The fed user has no account yet,
    # create one based on the info returned by shibboleth
    if params[:new_account]
      token = find_or_create_token()
      token.user = create_account(shib_name_from_session(),
                                  shib_email_from_session(),
                                  shib_login_from_session())
      if token.user
        logger.info "Shibboleth: shib user associated to new user #{token.user.inspect}"
        token.data = shib_data_from_session()
        token.save!
        flash[:success] = t('shibboleth.create.account_created', :url => lost_password_path)
      else
        flash[:error] = t('shibboleth.create.existent_email', :email => shib_email_from_session())
      end

    # Associate the shib user with an existing user account
    elsif params[:existing_account]

      # Tries to authenticate the user
      # see: station/lib/action_controller/sessions/login_and_password.rb#create_session_with_login_and_password
      agent = nil
      ActiveRecord::Agent.authentication_classes(:login_and_password).each do |klass|
        agent = klass.authenticate_with_login_and_password(params[:login], params[:password])
        break if agent
      end

      # Let the user log in even if not activated yet
      if agent && !agent.disabled
        logger.info "Shibboleth: shib user associated to a valid user #{agent.inspect}"
        token = find_or_create_token()
        token.user = agent
        token.data = shib_data_from_session()
        token.save!
        flash[:success] = t("shibboleth.create.account_associated", :login => agent.login)
      elsif agent && agent.disabled
        logger.info "Shibboleth: shib user associated to a disabled user #{agent.inspect}"
      else
        logger.info "Shibboleth: invalid user or password #{agent.inspect}"
        flash[:error] = t("shibboleth.create.invalid_credentials")
      end
    end

    redirect_to shib_login_path
  end

  def info
    @data = session[:shib_data] if session.has_key?(:shib_data)
    render :layout => false
  end

  private

  # Checks if shibboleth is enabled in the current site.
  def check_shib_enabled
    unless current_site.shib_enabled
      logger.info "Shibboleth: tried to access but shibboleth is disabled"
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

  # Checks if the required information for shibboleth to work is
  # available in the session.
  def check_shib_information
    unless session[:shib_data] &&
        shib_email_from_session() &&
        shib_name_from_session()

      logger.info "Shibboleth: failed to find shib information in the session, " +
        "data: #{session[:shib_data].inspect}"

      flash[:error] = t("shibboleth.create.data_error")
      render 'error', :layout => 'application_without_sidebar'
      false
    else
      true
    end
  end

  # Stores any shibboleth variable in the session
  # Uses the variables defined in Site#shib_env_variables if any,
  # otherwise use all variables that start with "shib-".
  # Comparisons are case-insensitive and trimmed.
  def shib_vars_to_session

    unless current_site.shib_env_variables.blank?
      vars = current_site.shib_env_variables
      vars = vars.split(/\r?\n/).map{ |s| s.strip().downcase() }
      filter = vars.map{ |v| /^#{v}$/  }
    else
      filter = /^shib-/
    end

    shib_data = {}
    request.env.each do |key, value|
      if filter.is_a?(Regexp)
        shib_data[key] = value if key.to_s.downcase =~ /^shib-/
      else
        unless filter.select{ |f| key.to_s.downcase =~ f }.empty?
          shib_data[key] = value
        end
      end
    end
    logger.info "Shibboleth: saving variables to session #{shib_data.inspect}, filter #{filter.inspect}"
    session[:shib_data] = shib_data

    shib_data
  end

  # Returns the shibboleth user email from the data stored in the session.
  def shib_email_from_session
    email = nil
    if session[:shib_data]
      email   = session[:shib_data][current_site.shib_email_field]
      email ||= session[:shib_data]["Shib-inetOrgPerson-mail"]
    end
    logger.info "Shibboleth: couldn't get email from session, " +
      "trying field #{current_site.shib_email_field} " +
      "in #{session[:shib_data].inspect}" if email.nil?
    email
  end

  # Returns the shibboleth user name from the data stored in the session.
  def shib_name_from_session
    name = nil
    if session[:shib_data]
      name   = session[:shib_data][current_site.shib_name_field]
      name ||= session[:shib_data]["Shib-inetOrgPerson-cn"]
    end
    logger.info "Shibboleth: couldn't get name from session, " +
      "trying field #{current_site.shib_name_field} " +
      "in #{session[:shib_data].inspect}" if name.nil?
    name
  end

  # Returns the shibboleth login from the data stored in the session.
  def shib_login_from_session
    login = nil
    if session[:shib_data]
      login   = session[:shib_data][current_site.shib_login_field]
      login ||= shib_name_from_session()
    end
    logger.info "Shibboleth: couldn't get login from session, " +
      "trying field #{current_site.shib_login_field} " +
      "in #{session[:shib_data].inspect}" if login.nil?
    login
  end

  # Returns the shibboleth data stored in the session.
  def shib_data_from_session
    session[:shib_data]
  end

  # Searches for a ShibToken using data in the session. Creates a new ShibToken
  # if nothing is found.
  def find_or_create_token
    email = shib_email_from_session()
    token = ShibToken.find_by_identifier(email)
    token = create_token(email) if token.nil?
    token
  end

  def create_account(name, email, login)
    unless User.find_by_email(email)
      password = SecureRandom.hex(16)
      user = User.create!(:login => login, :email => email,
                          :password => password, :password_confirmation => password)
      user.activate
      user.profile.update_attributes(:full_name => name)
      user
    else
      nil
    end
  end

  def create_token(id)
    ShibToken.create!(:identifier => id)
  end

  def test_data
    # FAKE TEST DATA
    request.env["Shib-Application-ID"] = "default"
    request.env["Shib-Session-ID"] = "09a612f952cds995e4a86ddd87fd9f2a"
    request.env["Shib-Identity-Provider"] = "https://login.somewhere/idp/shibboleth"
    request.env["Shib-Authentication-Instant"] = "2011-09-21T19:11:58.039Z"
    request.env["Shib-Authentication-Method"] = "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport"
    request.env["Shib-AuthnContext-Class"] = "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport"
    request.env["Shib-brEduPerson-brEduAffiliationType"] = "student;position;faculty"
    request.env["Shib-eduPerson-eduPersonPrincipalName"] = "75a988943825d2871e1cfa75473ec0@ufrgs.br"
    request.env["Shib-inetOrgPerson-cn"] = "Rick Astley"
    request.env["Shib-inetOrgPerson-sn"] = "Rick Astley"
    request.env["Shib-inetOrgPerson-mail"] = "nevergonnagiveyouup@rick.com"
    request.env["cn"] = "Rick Astley"
    request.env["mail"] = "nevergonnagiveyouup@rick.com"
    request.env["ufrgsVinculo"] = "anything in here"
    request.env["uid"] = "00000000000"
  end

end
