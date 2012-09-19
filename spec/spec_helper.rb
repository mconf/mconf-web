# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'shoulda-matchers'
require 'cancan/matchers'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

# ALL actions possible in our cancan Ability class should be here
# including our custom actions
Shoulda::Matchers::ActiveModel::BeAbleToDoAnythingToMatcher.
  actions = [
    :read, :create, :update, :destroy, :manage, # standard
    :reply_post,                                # posts
    :leave                                      # spaces
  ]

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.deliveries = []

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # Make the rails routes avaiable in all specs
  #config.include Rails.application.routes.url_helpers

  # we don't run migration specs all the time
  # TODO: how to filter migration specs here but override it in command line
  config.filter_run_excluding :migration => true
  config.run_all_when_everything_filtered = true

  config.include Devise::TestHelpers, :type => :controller
  #config.extend ControllerMacros, :type => :controller
end
