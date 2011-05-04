MAIL_CONFIG = YAML.load_file(File.join(Rails.root, "config", "mail_conf.yml"))

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
    :user_name            => MAIL_CONFIG["username"],
    :password             => MAIL_CONFIG["password"]
}
