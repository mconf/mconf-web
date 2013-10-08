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
        "in: #{session.has_key?(:shib_data) ? session[:shib_data].inspect : nil}"
      flash[:error] = t("shibboleth.login.not_enough_data")
      render 'error'
    else

      # the fields that define the name and email are configurable in the Site model
      shib_name = shib.get_name
      shib_email = shib.get_email

      # uses the fed email to check if the user already has an account
      user = User.find_by_email(shib_email)

      # the user already has an account but it was not activated yet
      if user and !user.active?
        @user = user
        render "need_activation"
        return
      end

      # the fed user has no account yet
      # create one based on the info returned by shibboleth
      if user.nil?
        password = SecureRandom.hex(16)
        user = User.create!(:username => shib_name.clone, :email => shib_email,
                            :password => password, :password_confirmation => password)
        user.activate
        user.profile.update_attributes(:full_name => shib_name)
        flash[:notice] = t('shibboleth.create.account_created', :url => new_user_password_path)
      end

      # login and go to home
      sign_in user, :bypass => true
      redirect_to my_home_path

    end
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

end
