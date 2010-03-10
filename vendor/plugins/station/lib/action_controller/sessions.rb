module ActionController #:nodoc:
  # Sessions module provides with Controller and Helper methods 
  # for sessions management
  #
  # This methods will be tipically used by SessionsController
  #
  # For identification issues in your Controllers, see ActionController::Authorization
  # For permissions issues in your Controllers, see ActionController::Authorization
  #
  module Sessions
    class << self
      def included(base) # :nodoc:
        base.__send__ :include, ActionController::Authentication unless base.ancestors.include?(ActionController::Authentication)

        ActiveRecord::Agent.authentication_methods.each do |method|
          mod = "ActionController::Sessions::#{ method.to_s.classify }".constantize
          base.__send__ :include, mod
        end
      end
    end

    # Authentication is supported in several ways; Login and password, OpenID, CAS, etc...
    #
    # Each of the modules define methods that should be called in each session stage: new, create, destroy.
    #
    # authentication_methods_chain evaluates each of the available methods, trying to authenticate one of the Agent classes.
    #
    # When one of the method performs the action, the chain stops. This is typical for redirections, like in OpenID.
    #
    # The chain is evaluated while the methods return nil.
    #
    # The chain is stopped when one of the methods returns an object. In the case of create, this object is the authenticated Agent.
    #
    #
    def authentication_methods_chain(controller_method_name, &block)
      authentication_methods.each do |authentication_method|
        chain_method = "#{ controller_method_name }_session_with_#{ authentication_method }"

        # Only call existing authentication methods
        next unless respond_to?(chain_method)

        # Evaluate this authentication method
        auth_response = __send__(chain_method)

        # End if the method has performed the renderization
        break if performed?

        # Return auth_response if authentication was successful
        return auth_response if auth_response
      end

      # If we reach here, none of the authentication methods succeeded
      nil
    end

    private

    # Array of Authentication methods used in this controller
    def authentication_methods
      ActiveRecord::Agent.authentication_methods
    end
  end
end
