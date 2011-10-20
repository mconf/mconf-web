# Initializes the ExceptionNotifier using the information stored in the current Site
# Works only in production
if Site.table_exists?
  site = Site.current
  if site.respond_to?(:email) && site.respond_to?(:email_password) &&
     site.email && site.email_password

    ActionMailer::Base.delivery_method = :smtp
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.raise_delivery_errors = true
    ActionMailer::Base.smtp_settings = {
      :enable_starttls_auto => true,
      :address              => 'smtp.gmail.com',
      :port                 => 587,
      :tls                  => true,
      :domain               => 'gmail.com',
      :authentication       => :plain,
      :user_name            => site.email,
      :password             => site.email_password
    }

  end
end
