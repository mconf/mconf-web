if configatron.exception_notification_enabled == "true"
  Vcc::Application.config.middleware.use ExceptionNotifier,
    :email_prefix => configatron.exception_notification_prefix,
    :sender_address => configatron.sendmail_username,
    :exception_recipients => configatron.exception_notification_recipients.split(" ")
end
