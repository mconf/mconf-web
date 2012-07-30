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
