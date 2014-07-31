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

  def self.setup_site_for_email_tests
    attributes = {
      :locale => "en",
      :smtp_sender => Faker::Internet.email,
      :name => Faker::Name.name
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
