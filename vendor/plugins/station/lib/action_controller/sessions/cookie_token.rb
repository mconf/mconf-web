module ActionController #:nodoc:
  module Sessions
    # Methods for Sessions based on CookieToken Authentication 
    #
    # CookieToken remembers the Autnentication in the browser for certain amount of time
    module CookieToken
      # Destroy CookieToken Session data
      def destroy_session_with_cookie_token
        current_agent.forget_me if authenticated?
        cookies.delete :auth_token
        nil
      end
    end
  end
end
