module ActiveRecord #:nodoc:
  module Agent
    # Agents Activation support
    #
    # Activation verifies the Agent has an accesible email
    #
    # TODO: Currently, only affects LoginAndPassword authentication
    module Activation
      def self.included(base) #:nodoc:
        base.class_eval do
          before_create "initialize_activation"
        end
      end

      # Activates the agent in the database.
      def activate
        @activated = true
        self.activated_at = Time.now.utc
        self.activation_code = nil
        save(false)
      end

      # Is the Agent activated?
      def active?
        # the existence of an activation code means they have not activated yet
        activation_code.nil?
      end

      # Returns true if the agent has just been activated.
      def recently_activated?
        @activated
      end

      protected

      def initialize_activation #:nodoc:
        make_activation_code unless activated_at
      end

      def make_activation_code #:nodoc:
        self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
      end
    end
  end
end
