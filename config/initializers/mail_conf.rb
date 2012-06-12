# Initializes the ExceptionNotifier using the information stored in the current Site
# Works only in production
if Site.table_exists?
  site = Site.current
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.perform_deliveries = true
  ActionMailer::Base.raise_delivery_errors = true

  settings={} 
  if site.respond_to?(:smtp_server) && not(site.smtp_server.empty?)
     settings[:address]=site.smtp_server
  elsif
     settings[:address]=nil
  end
  
  if site.respond_to?(:port) && site.smtp_port
     settings[:port]=site.smtp_port
  elsif
     settings[:port]=25
  end     
  if site.respond_to?(:domain) && site.domain
     settings[:domain]=site.domain
  elsif
     settings[:domain]=nil
  end
  
  if site.respond_to?(:smtp_auto_tls) && (site.smtp_auto_tls)
     settings[:enable_starttls_auto]= true
  else
     settings[:enable_starttls_auto]= nil
  end
  
  if site.respond_to?(:smtp_auth_type) && not(site.smtp_auth_type.empty?)
     settings[:authentication]=site.smtp_auth_type
  elsif
     settings[:authentication]=nil
  end

  if site.respond_to?(:smtp_use_tls) && (site.smtp_use_tls)
     settings[:tls]=true
  else
     settings[:tls]=nil
  end
  
  if site.respond_to?(:smtp_login) && not(site.smtp_login.empty?)
     settings[:user_name]=site.smtp_login
  elsif
     settings[:user_name]=nil
  end

  if site.respond_to?(:smtp_password) && not(site.smtp_password.empty?)
     settings[:password]=site.smtp_password
  elsif
     settings[:password]=nil
  end
  ActionMailer::Base.smtp_settings=settings

   
end
