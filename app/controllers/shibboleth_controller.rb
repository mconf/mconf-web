# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'uri'
require 'net/http'
require 'mconf/shibboleth'

class ShibbolethController < ApplicationController

  respond_to :html
  layout 'no_sidebar'

  before_filter :check_shib_enabled, :except => [:info]
  before_filter :check_current_user, :except => [:info]
  before_filter :load_shib_session
  before_filter :save_shib_to_session, only: [:login]
  before_filter :check_shib_always_new_account, :only => [:create_association]

  # Log in a user using his shibboleth information
  # The application should only reach this point after authenticating using Shibboleth
  # The authentication is currently made with the Apache module mod_shib
  def login
    unless @shib.has_basic_info
      logger.error "Shibboleth: couldn't find basic user information from session, " +
        "searching fields #{@shib.basic_info_fields.inspect} " +
        "in: #{@shib.get_data.inspect}"
      @attrs_required = @shib.basic_info_fields
      @attrs_informed = @shib.get_data
      render :attribute_error
    else
      token = @shib.find_token()

      # there's a token with a user associated
      if !token.nil? && !token.user_with_disabled.nil?
        user = token.user_with_disabled
        if user.disabled
          logger.info "Shibolleth: user local account is disabled, can't login"
          flash[:error] = t('shibboleth.login.local_account_disabled')
          redirect_to root_path
        else
          # the user is not disabled, logs the user in
          logger.info "Shibboleth: logging in the user #{token.user.inspect}"
          logger.info "Shibboleth: shibboleth data for this user #{@shib.get_data.inspect}"
          if token.user.active_for_authentication?
            sign_in token.user
            flash.keep # keep the message set before by #create_association
            redirect_to after_sign_in_path_for(token.user)
          else
            # go to the pending approval page without a flash msg, the page already has a msg
            flash.clear
            redirect_to my_approval_pending_path
          end
        end

      # no token means the user has no association yet, render a page to do it
      else
        if !get_always_new_account
          logger.info "Shibboleth: first access for this user, rendering the association page"
          render :associate
        else
          logger.info "Shibboleth: flag `shib_always_new_account` is set"
          logger.info "Shibboleth: first access for this user, automatically creating a new account"
          associate_with_new_account(@shib)
          redirect_to shibboleth_path
        end
      end
    end
  end

  # Associates the current shib user with an existing user or
  # a new user account (created here as well).
  def create_association

    # The federated user has no account yet, create one based on the info returned by
    # shibboleth
    if params[:new_account]
      associate_with_new_account(@shib)

    # Associate the shib user with an existing user account
    elsif params[:existent_account]
      associate_with_existent_account(@shib)

    # invalid request
    else
      flash[:notice] = t('shibboleth.create_association.invalid_parameters')
    end

    redirect_to shibboleth_path
  end

  def info
    @data = @shib.get_data
    render :layout => false
  end

  private

  def load_shib_session
    logger.info "Shibboleth: creating a new Mconf::Shibboleth object"
    @shib = Mconf::Shibboleth.new(session)
  end

  def save_shib_to_session
    logger.info "Shibboleth: saving env to session"
    @shib.save_to_session(request.env, Site.current.shib_env_variables)
  end

  # Checks if shibboleth is enabled in the current site.
  def check_shib_enabled
    unless current_site.shib_enabled
      logger.info "Shibboleth: tried to access but shibboleth is disabled"
      redirect_to login_path
      false
    else
      true
    end
  end

  # If there's a current user redirects to home.
  def check_current_user
    if user_signed_in?
      redirect_to after_sign_in_path_for(current_user)
      false
    else
      true
    end
  end

  # Renders a 404 if the flag `shib_always_new_account` is enabled.
  def check_shib_always_new_account
    if get_always_new_account()
      raise ActionController::RoutingError.new('Not Found')
    else
      true
    end
  end

  # When the user selected to create a new account for his shibboleth login.
  def associate_with_new_account(shib)
    token = shib.find_or_create_token()

    # if there's already a user and an association, we don't need to do anything, just
    # return and, when the user is redirected back to #login, the token will be checked again
    if token.user.nil?

      token.user = shib.create_user
      unless token.user.nil?
        if token.user.errors.empty?
          logger.info "Shibboleth: created a new account: #{token.user.inspect}"
          token.data = shib.get_data()
          token.save! # TODO: what if it fails
          flash[:success] = t('shibboleth.create_association.account_created', :url => new_user_password_path)
        else
          token.destroy
          logger.info "Shibboleth: error saving the new user created: #{token.user.errors.full_messages}"
          flash[:error] = t('shibboleth.create_association.error_saving_user', :errors => token.user.errors.full_messages.join(', '))
        end
      else
        token.destroy
        logger.info "Shibboleth: there's already a user with this email #{shib.get_email}"
        flash[:error] = t('shibboleth.create_association.existent_account', :email => shib.get_email)
      end
    end
  end

  # When the user selected to associate his shibboleth login with an account that already
  # exists.
  def associate_with_existent_account(shib)

    # try to authenticate the user with his login and password
    valid = false
    if params.has_key?(:user)
      # rejects anything but login and password to prevent errors
      password = params[:user][:password]
      params[:user].reject!{ |k, v| k.to_sym != :login }
      user = User.find_first_by_auth_conditions(params[:user])
      valid = user.valid_password?(password) unless user.nil?
    end

    # the user doesn't exist or the authentication was invalid (wrong username/password)
    if user.nil? or !valid
      logger.info "Shibboleth: invalid user or password #{user.inspect}"
      flash[:error] = t("shibboleth.create_association.invalid_credentials")

    # got the user and authenticated, but the user is disabled, can't let him be used
    elsif user.disabled
      logger.info "Shibboleth: attempt to associate with a disabled user #{user.inspect}"
      # don't need to tell the user the account is disabled, pretend it doesn't exist
      flash[:error] = t("shibboleth.create_association.invalid_credentials")

    # got the user and authenticated, everything ok
    else
      logger.info "Shibboleth: shib user associated to a valid user #{user.inspect}"
      token = shib.find_or_create_token()
      token.user = user
      token.data = shib.get_data()
      token.save! # TODO: what if it fails
      flash[:success] = t("shibboleth.create_association.account_associated", :email => user.email)
    end

  end

  # Returns the value of the flag `shib_always_new_account`.
  def get_always_new_account
    return Site.current.shib_always_new_account
  end

  # Adds fake test data to the environment to test shibboleth in development.
  def test_data
    if Rails.env == "development"
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
    end
  end
end
