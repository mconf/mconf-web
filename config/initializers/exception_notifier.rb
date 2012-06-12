# Initializes the ExceptionNotifier using the information stored in the current Site
# Works only in production
if Rails.env.production? and Site.table_exists?
  site = Site.current
  if site.respond_to?(:exception_notifications) && site.exception_notifications
    recipients = site.exception_notifications_email.split(/[\s,;]/).reject(&:empty?) # accepts " ", "," and ";" as separators
    Mconf::Application.config.middleware.use ExceptionNotifier,
      :email_prefix => site.exception_notifications_prefix + " ",
      :sender_address => %("#{site.name}" <#{site.smtp_login}>),
      :exception_recipients => recipients
  end
end
