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
      locale: "en",
      events_enabled: true,
      local_auth_enabled: true,
      registration_enabled: true,
      require_registration_approval: false,
      shib_enabled: false,
      shib_always_new_account: false,
      ldap_enabled: false,
      exception_notifications: false,
      webconf_auto_record: true,
      smtp_sender: Forgery::Internet.email_address,
      name: Forgery::Name.first_name
    }
    Site.current.update_attributes(attributes)
  end

  module ClassMethods

    # Sets the custom actions that should also be checked by
    # the matcher BeAbleToDoAnythingToMatcher
    def set_custom_ability_actions(actions)
      before(:each) do
        Shoulda::Matchers::ActiveModel::BeAbleToDoAnythingToMatcher.
          custom_actions = actions
      end
    end

  end

end
