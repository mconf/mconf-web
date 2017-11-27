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
      domain: Forgery::Internet.domain_name,
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
      smtp_sender: Forgery::Internet.email_address,
      ssl: false
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

  def self.reload_routes!
    Mconf::Application.reload_routes!
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

    # Returns the body of the email. For multi-part emails, always returns the first part.
    def mail_body(mail)
      if mail.parts.length > 0
        body = mail.parts.first.body
      else
        body = mail.body
      end
      if body.parts.length > 0
        body.parts.first.body
      else
        body
      end
    end

    # Returns the best match for the content of an email, formatted in a way to make
    # it easier to match on tests.
    def mail_content(mail)
      content = mail_body(mail).raw_source.gsub(/\r\n/, ' ').gsub(/\n/, ' ')
      if content.blank?
        mail_body(mail).encoded.gsub(/(=)?\r\n/, ' ').gsub(/(=)?\n/, ' ')
      else
        content
      end
    end

    def set_conf_scope_rooms(value)
      before {
        @previous_conf_scope_rooms = Rails.application.config.conf_scope_rooms
        Rails.application.config.conf_scope_rooms = value
        Helpers.reload_routes!
      }
      after {
        Rails.application.config.conf_scope_rooms = @previous_conf_scope_rooms
        Rails.application.reload_routes!
      }
    end
  end

end
