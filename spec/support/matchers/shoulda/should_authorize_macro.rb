# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# Ensures the model has an attr_accessor, attr_reader or attr_writer
# Examples:
#   it { should_authorize(Model, :method, :via => :http_method, :parameters) }
#   it { should_authorize(User, :index) }
#   it { should_authorize(an_instance_of(Space), :create, :via => :post, :space => {:name => 'space'} ) }

module Shoulda
  module Matchers
    module ActiveModel # :nodoc

      def should_authorize(target, method, options={})
        options[:via] ||= :get

        # For abilities with custom names like authorize!(@space,:index_join_requests)
        # which is called in join_requests#index
        if options[:ability_name]
          ability_name = options[:ability_name]
        else
          ability_name = method
        end

        unless [:get, :post, :put, :delete].include?(options[:via])
          fail "#{options[:via]} is not a valid http method"
        end
        http_method = options.delete(:via)

        controller.should_receive(:authorize!).with(ability_name, target).and_raise(CanCan::AuthorizationNotPerformed)
        begin
          send(http_method, method, options)
        rescue CanCan::AuthorizationNotPerformed
          # doesnt matter if no authorization is performed
        end
      end

    end
  end
end
