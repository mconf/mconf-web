module Mconf

  # A class to handle all exceptions raised while sending emails.
  class MailerErrorHandler

    def self.handle mailer, message, error, action, args
      Rails.logger.error "MailerErrorHandler: Handling email error on #{mailer.inspect}@#{action.inspect}"
      Rails.logger.error "MailerErrorHandler: Exception is #{error.inspect}"
      case action
      when "invitation_email"
        invitation = Invitation.find_by_id(args[0])
        if invitation.nil?
          Rails.logger.error "MailerErrorHandler: Could not find the Invitation #{args[0]}, won't mark it as not sent"
        else
          Rails.logger.error "MailerErrorHandler: Marking an invitation as failed: #{invitation.inspect}"
          # we just want to mark it as not sent, but raise the error afterwards
          invitation.result = false
          invitation.save!
        end
      end

      raise error
    end

  end
end
