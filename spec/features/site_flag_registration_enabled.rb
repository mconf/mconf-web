require 'spec_helper'
require 'support/feature_helpers'

feature 'Behaviour of the flag Site#registration_enabled' do
  let(:user) { FactoryGirl.create(:user) }

  context "when the flag is set" do
    before { Site.current.update_attributes(registration_enabled: true) }

    scenario "shows the 'register' link in the login page"
    scenario "shows the 'register' link in the navbar"
    scenario "shows the 'resend confirmation email' in the login page"
    scenario "events/index shows a link for anonymous to register"
    scenario "spaces/index shows a link for anonymous to register"
    scenario "the home of a space shows a link for anonymous to register"

  end

  context "when the flag is not set" do
    before { Site.current.update_attributes(registration_enabled: false) }

    scenario "hides the 'register' from the login page"
    scenario "hides the 'register' from the navbar"
    scenario "hides the 'resend confirmation email' from the login page"
    scenario "events/index shows a link for anonymous to sign in"
    scenario "spaces/index shows a link for anonymous to sign in"
    scenario "the home of a space shows a link for anonymous to sign in"

  end
end
