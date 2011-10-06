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
  layout 'clean'
  layout false, :only => [:info]

  # Log in a user using his shibboleth information
  # The application should only reach this point after authenticating using Shibboleth
  # The authentication is currently made with the Apache module mod_shib
  def create

    #################################
    # FAKE TEST DATA
    # shib_name = "JOAO DA SILVA"
    # shib_email = "invalido@ufrgs.br"
    # request.env["Shib-Application-ID"] = "default"
    # request.env["Shib-Session-ID"] = "09a612f952cc5995e4a86ddd87fd9f2a"
    # request.env["Shib-Identity-Provider"] = "https://login.teste.ufrgs.br/idp/shibboleth"
    # request.env["Shib-Authentication-Instant"] = "2011-09-21T19:11:58.039Z"
    # request.env["Shib-Authentication-Method"] = "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport"
    # request.env["Shib-AuthnContext-Class"] = "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport"
    # request.env["Shib-brEduPerson-brEduAffiliationType"] = "student;position;faculty"
    # request.env["Shib-eduPerson-eduPersonPrincipalName"] = "ef775988943825d2871e1cfa75473ec0@ufrgs.br"
    # request.env["Shib-inetOrgPerson-cn"] = "JOAO DA SILVA"
    # request.env["Shib-inetOrgPerson-mail"] = "invalido@ufrgs.br"
    # request.env["Shib-inetOrgPerson-sn"] = "JOAO DA SILVA"
    #################################

    # stores any "Shib-" variable in the session
    shib_data = {}
    request.env.each do |key, value|
      shib_data[key] = value if key.to_s.downcase =~ /^shib-/
    end
    session[:shib_data] = shib_data

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
      user = User.create!(:login => shib_name.clone, :email => shib_email,
                          :password => password, :password_confirmation => password)
      user.activate
      user.profile.update_attributes(:full_name => shib_name)
      flash[:notice] = t('shibboleth.create.account_created', :url => lost_password_path)
    end

    # login and go to home
    self.current_agent = user
    redirect_to home_path
  end

  def info
    @data = session[:shib_data] if session.has_key?(:shib_data)
  end

end
