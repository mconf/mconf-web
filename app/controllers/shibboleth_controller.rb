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

  before_filter :check_shib_enabled
  before_filter :check_current_user

  # Log in a user using his shibboleth information
  # The application should only reach this point after authenticating using Shibboleth
  # The authentication is currently made with the Apache module mod_shib
  def login
    shib = Mconf::Shibboleth.new(session)
    shib.save_to_session(request.env, Site.current.shib_env_variables)

    unless shib.has_basic_info
       "Shibboleth: couldn't basic user information from session, " +
        "searching fields #{shib.basic_info_fields.inspect} " +
        "in: #{shib.get_data.inspect}"
      flash[:error] = t("shibboleth.login.not_enough_data")
      render 'error'
    else
      token = shib.find_token()

      # there's a token with a user associated, logs the user in
      unless token.nil? || token.user.nil?
        logger.info "Shibboleth: logging in the user #{token.user.inspect}"
        sign_in token.user # TODO: review if we need `:bypass => true`
        # TODO: review `flash.keep :success`
        redirect_to my_home_path

      # no token means the user has no association yet, render a page to do it
      else
        logger.info "Shibboleth: first access for this user, rendering the association page"
        respond_to do |format|
          format.html
        end
      end
    end
  end

  # Associates the current shib user with an existing user or
  # a new user account (created here as well).
  def create_association
    # TODO: check if the session is before proceeding

    shib = Mconf::Shibboleth.new(session)

    # The federated user has no account yet, create one based on the info returned by
    # shibboleth
    if params[:new_account]
      associate_with_new_account(shib)
      redirect_to shibboleth_path

    # Associate the shib user with an existing user account
    # TODO: this entire block has to be reviewed and tested
    elsif params[:existing_account]

      # params[:scope] = :user
      # warden.authenticate!(params)
      #authenticate_user!
      user = User.find_first_by_auth_conditions(params[:user])
      valid = user.valid_password?(params[:user][:password]) unless user.nil?

      if user.nil? or !valid
        logger.info "Shibboleth: invalid user or password #{user.inspect}"
        flash[:error] = t("shibboleth.create.invalid_credentials")
      elsif user.disabled
        logger.info "Shibboleth: attempt to associate with a disabled user #{user.inspect}"
        flash[:error] = t("shibboleth.create.invalid_credentials")
      else !user.disabled
        logger.info "Shibboleth: shib user associated to a valid user #{user.inspect}"
        token = shib.find_or_create_token()
        token.user = user
        token.data = shib.get_data()
        token.save! # TODO: what if it fails
        flash[:success] = t("shibboleth.create.account_associated", :login => user.login)
      end

      redirect_to shibboleth_path

    # invalid request
    else
      flash[:notice] = t('shibboleth.create_association.invalid_parameters')
      redirect_to shibboleth_path
    end

  end

  def info
    @data = Mconf::Shibboleth.new(session).get_data
    render :layout => false
  end

  private

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
      redirect_to my_home_path
      false
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
          # TODO: this error should give the user more information about what he should do next
          flash[:error] = t('shibboleth.create_association.error_saving_user', :errors => token.user.errors.full_messages.join(', '))
        end
      else
        token.destroy
        logger.info "Shibboleth: there's already a user with this email #{shib.get_email}"
        flash[:error] = t('shibboleth.create_association.existent_account', :email => shib.get_email)
      end
    end
  end

end
