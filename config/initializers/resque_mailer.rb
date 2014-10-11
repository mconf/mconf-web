Resque::Mailer.excluded_environments = []

Resque::Mailer.error_handler = lambda { |mailer, message, error, action, args|
  Mconf::MailerErrorHandler.handle mailer, message, error, action, args
}

# Wrap devise email calls in the current locale for the user being emailed
# and in case of a new user, use the site's locale
module Devise
  module Async
    module Backend
      class Resque < Base
        extend Mconf::LocaleControllerModule

        def self.perform(*args)
          klass = args[1].constantize
          record = klass.find(args[2])
          I18n.with_locale(get_user_locale(record, nil)) do
            new.perform(*args)
          end
        end

      end
    end
  end
end