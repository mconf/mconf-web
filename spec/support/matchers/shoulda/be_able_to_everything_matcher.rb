# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# Check if the subject can do evrything to the target.
# It's the opposite of the matcher "not be_able_to_do_anything".
#
# IMPORTANT: Only works when used with "should".
#
# Examples:
#   it { should be_able_to_do_everything_to(object) }
#   it { should be_able_to_do_everything_to(object).except(:show) }
#
# If your target object has custom actions, you have to set them first, otherwise
# they won't be considered! You can do something like this in your :
#
#   module Helpers
#     module ClassMethods
#       # Sets the custom actions that should also be checked by
#       # the matcher BeAbleToDoEverythingToMatcher
#       def set_custom_ability_actions(actions)
#         before(:each) do
#           Shoulda::Matchers::ActiveModel::BeAbleToDoEverythingToMatcher.custom_actions = actions
#         end
#       end
#     end
#   end
#
#   # in your `spec_helper.rb`:
#   config.extend Helpers::ClassMethods
#
#   # in your specs:
#   set_custom_ability_actions([:play, :other_custom_action])
#
module Shoulda
  module Matchers
    module ActiveModel # :nodoc

      def be_able_to_do_everything_to(target)
        BeAbleToDoEverythingToMatcher.new(target)
      end

      class BeAbleToDoEverythingToMatcher < ValidationMatcher # :nodoc:

        # all RESTful actions in Rails plus the aliases defined by CanCan,
        # see https://github.com/ryanb/cancan/wiki/Action-Aliases
        cattr_accessor 'actions'
        @@actions = [:update, :create, :destroy, :manage, :show, :index, :edit, :new]

        cattr_accessor 'custom_actions'
        @@custom_actions = []

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

          @all_actions = @@actions + @@custom_actions
          @can = @all_actions.select {|a| subject.can?(a, @target)}

          @can.sort.uniq == (@all_actions - @exceptions).sort.uniq
        end

        def description
          desc = "be able to do everything to the object"
          unless @exceptions.empty?
            desc += " except #{@exceptions}"
          end
          desc
        end

        def failure_message
          m = "Expected #{@subject.class.name} to be able to do everything with '#{@target}'"
          unless @exceptions.empty?
            m += " except #{@exceptions.sort.uniq},"
          end
          m += " but it cannot #{(@all_actions - @can).sort.uniq}"
          m
        end
        alias failure_message_for_should failure_message

        def failure_message_for_should_not
          "Don't use this matcher with 'should_not'. See 'be_able_to_do_anything_to'."
        end

      end
    end
  end
end
