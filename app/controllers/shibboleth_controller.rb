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

  def create

    # TODO: accept any Shib_ key
    @data = { }
    keys = ["Shib-Application-ID", "Shib-Session-ID", "Shib-Identity-Provider", "Shib-Authentication-Instant",
            "Shib-Authentication-Method", "Shib-AuthnContext-Class", "Shib-eduPerson-eduPersonPrincipalName",
            "Shib-eduPerson-eduPersonAffiliation", "Shib-brPerson-brPersonCPF", "Shib-brPerson-brPersonPassport",
            "Shib-inetOrgPerson-cn", "Shib-inetOrgPerson-sn", "Shib-inetOrgPerson-mail", "Shib-brEduPerson-brEduAffiliationType"]
    keys.each do |k|
      request.env.has_key?(k)
      @data[k] = request.env[k]
    end

    # TODO temp
    # @data["Shib-inetOrgPerson-sn"] = "JOAO DA SILVA"
    # @data["Shib-inetOrgPerson-mail"] = "invalido@ufrgs.br"

    # create the user based on the info returned by shibboleth
    password = SecureRandom.hex(16)
    user = User.create!(:login => @data["Shib-inetOrgPerson-sn"].downcase.parameterize,
                        :email => @data["Shib-inetOrgPerson-mail"],
                        :password => password, :password_confirmation => password)
    user.activate
    user.profile.update_attributes(:full_name => @data["Shib-inetOrgPerson-sn"].titleize)

    # TODO: create associated table
    # TODO: check duplicated email/login

    # login and go to home
    self.current_agent = user
    redirect_to home_path
  end

end
