module ActiveRecord #:nodoc:
  module Agent
    # Reset password support
    module PasswordReset
      # Activate agent recovery password mechanism. 
      # Generates password reset code
      def lost_password
        @lost_password = true
        self.make_reset_password_code
        save(false)
      end

      # User did reset the password
      def reset_password
        @reset_password = true
        self.reset_password_code = nil

        # Active agent if pending, since she has verified her email
        ! active? ?
          activate :
          save(false)
      end

      # Did the agent recently reset the passowrd?
      def recently_reset_password?
        @reset_password
      end

      # Did the agent recently asked for password reset?
      def recently_lost_password?
        @lost_password
      end

      protected

      def make_reset_password_code #:nodoc:
        self.reset_password_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
      end
    end
  end
end
