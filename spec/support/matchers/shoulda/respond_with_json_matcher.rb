# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

module Shoulda # :nodoc:
  module Matchers
    module ActionController # :nodoc:

      # Ensures a controller responded with the expected json.
      def respond_with_json(status)
        RespondWithJsonMatcher.new(status)
      end

      class RespondWithJsonMatcher # :nodoc:

        def initialize(expected_json)
          @no_values = false
          @ignored = []
          @expected = expected_json
        end

        def ignoring_attributes(ignored = ['id', 'updated_at', 'created_at'])
          @ignored = ignored
          self
        end

        def ignoring_values()
          @no_values = true
          self
        end

        def matches?(controller)
          @actual = controller.response.body

          # remove the selected attributes
          @ignored.each do |attr|
            @actual.gsub!(/.#{attr}.:[^{,]*[,]+/, "")
            @expected.gsub!(/.#{attr}.:[^{,]*[,]+/, "")
          end
          # remove the values of all attributes
          if @no_values
            @actual.gsub!(/:[^{,]*/, "")
            @expected.gsub!(/:[^{,]*/, "")
          end

          @actual == @expected
        end

        def failure_message
          s = "Expected the following json strings to be equal: \n"
          s += "Expected: " + @expected.inspect + "\n"
          s += "     Got: " + @actual.inspect
          s
        end

        def negative_failure_message
          s = "Expected the following json strings to be different: \n"
          s += "Expected: " + @expected.inspect + "\n"
          s += "     Got: " + @actual.inspect
          s
        end

        def description
          "respond with a defined json string"
        end

      end

    end
  end
end
