# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# Check if the subject can(not) do anything to the target.
# Exists because "should be_able_to(:manage, target)" guarantees that
# a user CAN do anything, but "should_not be_able_to(:manage, target)"
# does not guarantee that a user cannot to anything, only that he
# cannot :manage the target (but he could be able to :read it, for instance).
# Only makes send when used with "should_not".
# Examples:
#   it { should_not be_able_to_do_anything_to(object) }
#   it { should_not be_able_to_do_anything_to(object).except(:read) }
module Shoulda
  module Matchers
    module ActiveModel # :nodoc

      def be_able_to_do_anything_to(target)
        BeAbleToDoAnythingToMatcher.new(target)
      end

      class BeAbleToDoAnythingToMatcher < ValidationMatcher # :nodoc:
        cattr_accessor 'actions'
        @@actions = [:read, :update, :create, :destroy, :manage]

        def initialize(target)
          @target = target
          @exceptions = []
        end

        def except(actions)
          @exceptions = [actions].flatten
          self
        end

        def matches?(subject)
          @subject = subject

          @can = @@actions.select {|a| subject.can?(a, @target)}

          # returning false means should_not is successful
          !(@can.sort == @exceptions.sort)
        end

        def description
          "ensure the subject can do anything to the target"
        end

        def failure_message
          "Don't use this matcher with 'should'. You might use replace it by 'be_able_to(:manage, target)'"
        end

        def negative_failure_message
          m = "Expected #{@subject.class.name} not to be able to do anything with '#{@target}'"
          unless @exceptions.empty?
            m += " except #{@exceptions},"
          end
          m += " but it can #{@can}"
          m
        end

      end
    end
  end
end
