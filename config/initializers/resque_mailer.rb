Resque::Mailer.excluded_environments = []

Resque::Mailer.error_handler = lambda { |mailer, message, error, action, args|
  if mailer.method_defined? :error_handler
    mailer.error_handler message, error, action, args
  else
    raise error
  end
}
