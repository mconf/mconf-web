# Override the simple_captcha save method. We don't need to validate the simple_captcha
# text when testing
module SimpleCaptcha
  module ModelHelpers
    module InstanceMethods
      def save_with_captcha
        save
      end
    end
  end
end
