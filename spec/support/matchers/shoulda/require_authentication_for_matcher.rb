# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

module Shoulda # :nodoc
  module Matchers
    module ActionController # :nodoc

      # Ensures that authentication is required to access a route.
      #
      # Options:
      # * <tt>via</tt> - Method to be used (default to get): :get, :post,
      #   :put, :delete.
      #
      # Example:
      #
      #   it { should require_authentication_for(:index) }
      def require_authentication_for(action, params=nil)
        RequireAuthenticationForMatcher.new(action, self, params)
      end

      class RequireAuthenticationForMatcher # :nodoc:

        def initialize(action, example_group, params)
          @action = action
          @example_group = example_group
          @params = params
          @route = "/users/login"
          @method = :get
        end

        def via(method)
          @method = method
          self
        end

        def matches?(controller)
          @controller = controller
          @example_group.send(@method, @action, @params)
          @matcher = RedirectToMatcher.new(@route, @example_group)
          @matcher.matches?(@controller)
        end

        def description
          "require authentication for '#{@method} :#{@action}'"
        end

        def failure_message
          "Expected '#{@method} :#{@action}' to require authentication (#{@matcher.failure_message})"
        end

        def negative_failure_message
          "Did not expect '#{@method} :#{@action}' to require authentication (#{@matcher.failure_message})"
        end

      end
    end
  end
end
