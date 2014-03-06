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

        if ![:get, :post, :put, :delete].include? options[:via]
          fail "#{options[:via]} is not a valid http method"
        end
        http_method = options.delete(:via)

        controller.should_receive(:authorize!).with(method, target)
        send(http_method, method, options)
      end

    end
  end
end