# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# Initializes the ExceptionNotifier using the information stored
# in the current Site. Works only in production.
ActiveSupport.on_load(:after_initialize) do

  if Site.table_exists?
    site = Site.current
    ActionMailer::Base.delivery_method = :smtp
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.raise_delivery_errors = true

    # default settings
    settings = {
      :address => nil,
      :port => 25,
      :domain => nil,
      :enable_starttls_auto => false,
      :authentication => nil,
      :tls => false,
      :user_name => nil,
      :password => nil
    }

    if site.respond_to?(:smtp_server) and not site.smtp_server.blank?
      settings[:address] = site.smtp_server
    end
    if site.respond_to?(:smtp_port) and not site.smtp_port.blank?
      settings[:port] = site.smtp_port
    end
    if site.respond_to?(:smtp_domain) and not site.smtp_domain.blank?
      settings[:domain] = site.smtp_domain
    end
    if site.respond_to?(:smtp_auto_tls) and not site.smtp_auto_tls.blank?
      settings[:enable_starttls_auto] = true
    end
    if site.respond_to?(:smtp_auth_type) and not site.smtp_auth_type.blank?
      settings[:authentication] = site.smtp_auth_type
    end
    if site.respond_to?(:smtp_use_tls) and not site.smtp_use_tls.blank?
      settings[:tls] = true
    end
    if site.respond_to?(:smtp_login) and not site.smtp_login.blank?
      settings[:user_name] = site.smtp_login
    end
    if site.respond_to?(:smtp_password) and not site.smtp_password.blank?
      settings[:password] = site.smtp_password
    end

    ActionMailer::Base.smtp_settings = settings
  end
end
