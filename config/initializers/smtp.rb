ActionMailer::Base.raise_delivery_errors = true
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  :address => "jungla.dit.upm.es",
  :port => 25,
  :domain => "dit.upm.es",
}

ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_charset = "utf-8"  
 
