Resque::Mailer.excluded_environments = []

Resque::Mailer.error_handler = lambda { |mailer, message, error, action, args|
  Mconf::MailerErrorHandler.handle mailer, message, error, action, args
}
