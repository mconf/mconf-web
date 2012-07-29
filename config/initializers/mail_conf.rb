# Initializes the ExceptionNotifier using the information stored in the current Site
# Works only in production
ActiveSupport.on_load(:after_initialize) do

  if Site.table_exists?
    site = Site.current

    ActionMailer::Base.default_url_options[:host] = site.domain
    if site.respond_to?(:email) && site.respond_to?(:email_password) &&
        site.email && site.email_password

      ActionMailer::Base.delivery_method = :smtp
      ActionMailer::Base.perform_deliveries = true
      ActionMailer::Base.raise_delivery_errors = true
      ActionMailer::Base.smtp_settings = {
        :enable_starttls_auto => true,
        :address              => 'smtp.gmail.com',
        :port                 => 587,
        :domain               => 'gmail.com',
        :authentication       => :plain,
        :user_name            => site.email,
        :password             => site.email_password
      }

    end
  end

end
