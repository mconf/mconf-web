module ActiveRecord #:nodoc:
  # Authorization module provides ActiveRecord descendants with an advanced authorization framework.
  #
  #  # Check if alice can update foo
  #  foo.authorize?(:update, :to => alice)
  #
  #  # Check if bob can delete bar
  #  bar.authorize?(:delete, :to => bob)
  #
  # Every ActiveRecord::Base descendant can authorize actions to Agents.
  #
  # == The Authorization Chain
  # Access Control policies are defining by the Authorization Chain.
  #
  # Each ActiveRecord model have an Authorization Chain (AC) associated. The AC is a sequence of 
  # Authorization Blocks (AB). Each AB should enclose only one security policy.
  #
  # When asking some model if some Agent is allowed to perform an action, the Authorization Chain is
  # evaluated. Each AB is executed in order. When one AB gives a result (true or false), the AC is
  # halted and action is allowed or denied.
  #
  # If the AB result is nil, the next AB is evaluated. When no AB remain, auhorization is denied.
  #
  # Authorization Blocks are defined using ActiveRecord::Authorization::ClassMethods#authorizing method.
  #
  # Consider the following example of Authorization Chain
  #
  #  # Foo's Authorization Chain:
  #  #   ---------------   -----------   -----------   --------------------
  #  # --| superadmin? |---| banned? |---| author? |---| [default policy] |
  #  #   ---------------   -----------   -----------   --------------------
  #
  #   class Foo
  #     authorizing do |agent, permission|
  #       if agent.is_superadmin?
  #         true
  #       end
  #     end
  #
  #     authorizing do |agent, permission|
  #       if agent.is_banned?
  #         false
  #       end
  #     end
  #
  #     authorizing do |agent, permission|
  #       if agent == self.author
  #         true
  #       end
  #     end
  #   end
  #
  # The class Foo has 3 Authorization Blocks, that will be evaluated in order until a response is obtained.
  #
  # Authorization is queried using ActiveRecord::Authorization::InstanceMethods#authorize? method.
  # For the example above:
  #   foo.authorize?(:read, :to => superadmin) #=> true
  #   foo.authorize?(:destroy, :to => banned_agent) #=> false
  #   foo.authorize?(:update, :to => example.author) #=> true
  #
  # Note that Authorization Blocks are evaluated in order. This configuration will allow the operation
  # to a banned superadmin because the first block grants the access:
  #   foo.authorize?(:read, :to => banned_superadmin) #=> true
  #
  # === Station default Authorization Blocks
  # Station provides 2 default Authorization Blocks for Contents and Stages. See ActiveRecord::Content and ActiveRecord::Stage
  #
  # == Authorization Cache
  # Permissions are cached for each ActiveRecord instance during the request. This improves performance
  # significantly.
  #
  # The cache consist on a Hash of Hashes, like:
  #   post.authorization_cache #=> { User.first => { :read => true, :update => false },
  #                           Anonymous.current => { :read => false } }
  #
  module Authorization
    class << self
      def included(base) #:nodoc:
        base.extend ClassMethods
        base.send :include, InstanceMethods
      end
    end

    module ClassMethods
      # The Authorization Chain of this model
      #
      def authorization_chain
        @authorization_chain ||= []
      end

      protected

      # Define a new Authorization Block.
      #
      # A sequence of Authorization Blocks compose the Authorization Chain. Each model AC is evaluated
      # when requesting authorization permissions to each instance. See ActiveRecord::Authorization
      #
      #   class User
      #     # Grants all permissions to self
      #     authorizing do |agent, permission|
      #       agent == self
      #     end
      #   end
      def authorizing(method = nil, &block)
        @authorization_chain = authorization_chain | Array(method || block)
      end

      def authorization_delegate(relation, options = {})
        options[:as] ||= name.underscore

        class_eval <<-AUTH
        authorizing do |agent, permission|
          return nil unless #{ relation }.present?

          return nil unless permission.is_a?(String) || permission.is_a?(Symbol)

          #{ relation }.authorize?([permission, :#{ options[:as] }], :to => agent,
                                                                     :default => nil)
        end
        AUTH
      end
    end

    # Instance methods can be redefined in each Model for custom features
    module InstanceMethods
      # Does this instance allows or denies permission?
      #
      # Is the response is cached, it is responded immediately.
      #
      # Else, the Authorization Chain is evaluated. 
      # See ActiveRecord::Authorization for information on how it works
      #
      # If the agent is not a SingularAgent, the Authorization Chain is also
      # evaluated for Authenticated and Anyone
      #
      # Permission can be:
      # Symbol:: describes the action name. Objective will be nil
      #   resource.authorize?(:update, :to => agent)
      # Array:: pair of :action, :objective
      #   resource.authorize?([ :create, :attachment ], :to => agent)
      #
      # Options:
      # to:: Agent that performs the operation. Defaults to Anyone
      # default:: Change the default policy. Defaults to denying permissions (false)
      #
      def authorize?(permission, options = {})
        agent = options.delete(:to) || Anyone.current

        authorization_eval(agent, permission, options)
      end

      #FIXME: DRY:
      def authorizes?(permission, options = {}) #:nodoc:
        logger.debug "Station: DEPRECATION WARNING \"authorizes?\". Please use \"authorize?\" instead."
        line = caller.select{ |l| l =~ /^#{ RAILS_ROOT }/ }.first
        logger.debug "           in: #{ line }"

        authorize?(permission, options)
      end

      private

      # Main entry for authorization evaluation
      def authorization_eval(agent, permission, options) #:nodoc:
        # Deny as default policy
        default = options.key?(:default) ? options[:default] : false

        auth_eval = authorization_cache_eval(agent, permission)

        auth_eval.nil? ? default : auth_eval
      end

      # Evaluate authorization with cache support. Improves performance
      def authorization_cache_eval(agent, permission, options = {}) #:nodoc:
        if authorization_cache[agent].key?(permission)
          authorization_cache[agent][permission]
        else
          authorization_cache[agent][permission] =
            authorization_agents_eval(agent, permission)
        end
      end

      # Evaluate authentication including SingularAgents
      #
      # When regular Agent, like a user, the authorization also includes Authenticated
      # and Anyone
      #
      # When Authenticated.current, also include Anyone
      #
      # Note that this method supports denying access to certain agents in the
      # Authorization Chain, despite authorization is granted to SingularAgents
      # Example:
      #
      #   class SecretResource
      #     authorizing do |agent, permission|
      #       false if agent.is_banned?
      #     end
      #
      #     authorizing do |agent, permission|
      #       true if agent.is_a?(Authenticated)
      #     end
      #   end
      #
      #   secret_resource.authorize?(:read, :to => user) #=> true
      #   secret_resource.authorize?(:read, :to => banned_user) #=> false
      #
      def authorization_agents_eval(agent, permission) #:nodoc:
        auth_eval = authorization_chain_eval(agent, permission)

        return auth_eval unless auth_eval.nil?

        unless agent.is_a?(SingularAgent)
          auth_eval = authorization_cache_eval(Authenticated.current, permission)

          return auth_eval unless auth_eval.nil?
        end

        unless agent.is_a?(Anyone)
          auth_eval = authorization_cache_eval(Anyone.current, permission)

          return auth_eval unless auth_eval.nil?
        end

        nil
      end

      # Evaluate Authorization Chain
      def authorization_chain_eval(agent, permission) #:nodoc:
        self.class.authorization_chain.each do |block|
          auth_block_eval = 
            case block
            when Symbol
              send(block, agent, permission)
            when Proc
              block.bind(self).call(agent, permission)
            else
              raise "Invalid Authorization Block #{ m }"
            end

          return auth_block_eval unless auth_block_eval.nil?
        end

        nil
      end

      # Authorization Cache
      def authorization_cache #:nodoc:
        @authorization_cache ||=
          Hash.new { |agent, permission| agent[permission] = Hash.new }
      end
    end
  end
end
