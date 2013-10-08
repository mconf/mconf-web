# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

module Mconf
  class Shibboleth

    def initialize(session)
      @session = session
    end

    def save_to_session(env_variables, filters='')
      unless filters.blank?
        vars = filters.clone
        vars = vars.split(/\r?\n/).map{ |s| s.strip.downcase }
        filter = vars.map{ |v| /^#{v}$/  }
      else
        filter = [/^shib-/]
      end

      shib_data = {}
      env_variables.each do |key, value|
        unless filter.select{ |f| key.to_s.downcase =~ f }.empty?
          shib_data[key.to_s] = value
        end
      end
      @session[:shib_data] = shib_data
      shib_data
    end

    def has_basic_info
      @session[:shib_data] && get_email() && get_name()
    end

    def get_email
      result = nil
      if @session[:shib_data]
        result   = @session[:shib_data][Site.current.shib_email_field]
        result ||= @session[:shib_data]["Shib-inetOrgPerson-mail"]
        result = result.clone unless result.nil?
      end
      result
    end

    def get_name
      result = nil
      if @session[:shib_data]
        result   = @session[:shib_data][Site.current.shib_name_field]
        result ||= @session[:shib_data]["Shib-inetOrgPerson-cn"]
        result = result.clone unless result.nil?
      end
      result
    end

    def basic_info_fields
      [ Site.current.shib_email_field || "Shib-inetOrgPerson-mail",
        Site.current.shib_name_field || "Shib-inetOrgPerson-cn" ]
    end

  end
end
