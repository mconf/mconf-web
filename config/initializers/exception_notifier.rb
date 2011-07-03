if configatron.exception_notification.enabled
  Vcc::Application.config.middleware.use ExceptionNotifier,
    :email_prefix => configatron.exception_notification.prefix,
    :sender_address => configatron.sendmail.username,
    :exception_recipients => configatron.exception_notification.recipients.split(" ")
end
