# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# Send devise mails with delayed_job
# From https://gist.github.com/659514
module Devise
  module Models
    module Confirmable
      handle_asynchronously :send_confirmation_instructions
      handle_asynchronously :send_on_create_confirmation_instructions
    end

    module Recoverable
      handle_asynchronously :send_reset_password_instructions
    end

    module Lockable
      handle_asynchronously :send_unlock_instructions
    end
  end
end
