# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# General purpose helpers
module Helpers

  # Creates `n` users as members of `space`
  def self.create_fellows(n, space)
    users = []
    n.times do
      u = FactoryGirl.create(:user)
      space.add_member! u
      users.push u
    end
    users
  end

  # Default site setup for tests
  # We don't rely on the setup_config.yml for tests because the user can changed it and it's
  # not on git.
  def self.setup_site
    attributes = {
      events_enabled: true,
      exception_notifications: false,
      ldap_enabled: false,
      local_auth_enabled: true,
      locale: "en",
      name: Forgery::Name.first_name,
      registration_enabled: true,
      require_registration_approval: false,
      shib_enabled: false,
      shib_always_new_account: false,
      smtp_sender: Forgery::Internet.email_address
    }
    Site.current.update_attributes(attributes)
    I18n.locale = "en"
  end

  def self.reload_seeds
    # db/seeds prints a lot of things to the console with puts, so we suppress it
    silence_stream(STDOUT) do
      load Rails.root + "db/seeds.rb"
    end
  end

  # Sets the custom actions that should also be checked by
  # the matcher BeAbleToDoAnythingToMatcher
  def self.set_custom_ability_actions(actions)
    Shoulda::Matchers::ActiveModel::BeAbleToDoAnythingToMatcher.
      custom_actions = actions
    Shoulda::Matchers::ActiveModel::BeAbleToDoEverythingToMatcher.
      custom_actions = actions
  end

  module ClassMethods

    def set_custom_ability_actions(actions)
      before { Helpers.set_custom_ability_actions(actions) }
    end

  end

end
