module Shoulda # :nodoc
  module Matchers
    module ActionController # :nodoc

      # Ensures that the given action is not forbidden (403)
      #
      # Options:
      # * <tt>with_response_code</tt> - Check failure againt this response code instead
      #   of the default 403.
      #
      # Example:
      #
      #   before { login_as(@user) }
      #   it { should allow_access_to(:index, :get) }
      #   it { should allow_access_to(:create, :post, { :id => @post }) }
      #   it { should_not allow_access_to(:update, :put, { :id => @post }) }
      #   it { should_not allow_access_to(:index, :get).with_response_code(:redirect) }
      def allow_access_to(action, method=nil, params=nil)
        AllowAccessToMatcher.new(action,  method || :get, params, self)
      end

      class AllowAccessToMatcher # :nodoc:

        def initialize(action, method, params, example_group)
          @method = method || :get
          @action = action
          @params = params
          @example_group = example_group
          @response_code = :forbidden
        end

        def with_response_code(code)
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

          !RespondWithMatcher.new(@response_code).matches?(@controller)
        end

        def description
          "ensures #{@method} => :#{@action} is accessible (not '#{@response_code}')"
        end

        def failure_message
          "Expected #{@method} => :#{@action} not to respond with '#{@response_code}'"
        end

        def negative_failure_message
          "Did not expected #{@method} => :#{@action} to respond with '#{@response_code}' (returned #{@controller.response.code})"
        end

      end
    end
  end
end
