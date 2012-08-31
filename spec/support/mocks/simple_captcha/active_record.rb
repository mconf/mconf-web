# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

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
