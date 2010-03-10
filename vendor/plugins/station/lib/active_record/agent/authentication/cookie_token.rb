module ActiveRecord #:nodoc:
  module Agent
    module Authentication
      # Remember Agent in browser beyond Rails Session using +auth_token+ cookie
      module CookieToken
        def remember_token?
          (!remember_token.blank?) &&
            remember_token_expires_at && (Time.now.utc < remember_token_expires_at.utc)
        end

        # Remember Agent in this browser for 2 weeks
        def remember_me
          remember_me_for 2.weeks
        end

        def remember_me_for(time) #:nodoc:
          remember_me_until time.from_now.utc
        end

        def remember_me_until(time) #:nodoc:
          self.remember_token_expires_at = time
          self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
          save(false)
        end

        # Remove Remember information
        def forget_me
          self.remember_token_expires_at = nil
          self.remember_token            = nil
          save(false)
        end
      end
    end
  end
end
