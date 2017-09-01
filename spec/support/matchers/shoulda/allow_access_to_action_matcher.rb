# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

module Shoulda # :nodoc
  module Matchers
    module ActionController # :nodoc

      # Ensures that the given action is not forbidden (403)
      #
      # Options:
      # * <tt>via</tt> - Method to be used (default to get): :get, :post,
      #   :put, :delete.
      # * <tt>redirecting_to</tt> - Check that the user was redirected to this
      #   route.
      #
      # Example:
      #
      #   before { login_as(@user) }
      #   it { should allow_access_to(:index) }
      #   it { should allow_access_to(:destroy).via(:delete) }
      #   it { should allow_access_to(:show).redirecting_to("/users/1") }
      #   it { should_not allow_access_to(:create, { :id => @post }).via(:post) }
      #   it { should_not allow_access_to(:update, { :id => @post }).via(:put) }
      #
      # Notes:
      #  * Avoid using negation with the `redirecting_to` option, we will not work
      #    as expected. Example:
      #      it { should_not allow_access_to(:show).redirecting_to("/users/1") } # BAD!
      #  * The target action is stubbed, so if you're using CanCan's `authorize!` inside
      #    the action, it will not work!
      def allow_access_to(action, params=nil)
        AllowAccessToMatcher.new(action, self, params)
      end

      class AllowAccessToMatcher # :nodoc:

        def initialize(action, example_group, params)
          @action = action
          @example_group = example_group
          @params = params
          @method = :get
          @redirecting_to = nil
          @xhr = false
        end

        def via(method)
          @method = method
          self
        end

        def xhr
          @xhr = true
          self
        end

        def redirecting_to(redirecting_to)
          @redirecting_to = redirecting_to
          self
        end

        def matches?(controller)
          @controller = controller
          @controller.stub(@action)

          begin
            if @xhr
              @example_group.send(:xhr, @method, @action, @params)
            else
              @example_group.send(@method, @action, @params)
            end

          # cancan error means we certainly had our access blocked
          rescue CanCan::AccessDenied
            r = false

          # missing template means the action was called
          rescue ActionView::MissingTemplate
            r = true

          # anything else means everything went fine, but we might have been redirected
          else

            # not expecting a redirect, so make sure it received a success response
            if @redirecting_to.nil?
              r = RespondWithMatcher.new(:success).matches?(@controller)

            # expecting a redirect, check to where the redirect was
            else
              r = RespondWithMatcher.new(:redirect).matches?(@controller) and
                RedirectToMatcher.new(@redirecting_to, @example_group).matches?(@controller)
            end

          end

          r
        end

        def description
          "allow access to '#{@method} :#{@action}'"
        end

        def failure_message
          desc = "Expected '#{@method} :#{@action}' to be accessible"
          unless @redirecting_to.nil?
            desc += ", checked using a redirect to #{@redirecting_to}"
          end
          desc
        end

        def negative_failure_message
          desc = "Did not expect '#{@method} :#{@action}' to be accessible"
          unless @redirecting_to.nil?
            desc += ", checked using a redirect to #{@redirecting_to}"
          end
          desc
        end

      end
    end
  end
end
