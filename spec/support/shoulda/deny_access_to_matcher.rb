module Shoulda # :nodoc
  module Matchers
    module ActionController # :nodoc

      # Ensures that the given action is not forbidden (403)
      #
      # Options:
      # * <tt>via</tt> - Method to be used (default to get): :get, :post,
      #   :put, :delete.
      # * <tt>using_code</tt> - Check againt this response code instead
      #   of the default 403.
      #
      # Example:
      #
      #   before { login_as(@user) }
      #   it { should deny_access_to(:index) }
      #   it { should deny_access_to(:destroy).via(:delete) }
      #   it { should deny_access_to(:index).using_code(:redirect) }
      #   it { should_not deny_access_to(:create, { :id => @post }).via(:post) }
      #   it { should_not deny_access_to(:update, { :id => @post }).via(:put) }
      def deny_access_to(action, params=nil)
        DenyAccessToMatcher.new(action, self, params)
      end

      class DenyAccessToMatcher # :nodoc:

        def initialize(action, example_group, params=nil)
          @action = action
          @example_group = example_group
          @params = params
          @method = :get
          @response_code = :forbidden
        end

        def via(method)
          @method = method
          self
        end

        def using_code(code)
          @response_code = code
          self
        end

        def matches?(controller)
          @controller = controller

          # we don't need to execute the real action to verify if it's accessible
          @controller.stub(@action)
          begin
            @example_group.send(@method, @action, @params)
          rescue ActionView::MissingTemplate
          end

          RespondWithMatcher.new(@response_code).matches?(@controller)
        end

        def description
          "ensures #{@method} => :#{@action} is forbidden (403 or the code given by the user)"
        end

        def failure_message
          "Expected #{@method} => :#{@action} to deny access with the response code '#{@response_code}' (returned #{@controller.response.code})"
        end

        def negative_failure_message
          "Did not expected #{@method} => :#{@action} to deny access respond with the response code '#{@response_code}'"
        end

      end
    end
  end
end
