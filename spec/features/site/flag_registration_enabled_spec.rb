# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'
require 'support/feature_helpers'

feature 'Behaviour of the flag Site#registration_enabled' do
  let(:user) { FactoryGirl.create(:user) }

  context "when the flag is set" do
    before { Site.current.update_attributes(registration_enabled: true) }

    context "shows links on the login page" do
      before { visit new_user_session_path }

      it { page.should have_content(t('devise.shared.links.register')) }
      it { page.should have_content(t('devise.shared.links.resend_confirmation_email')) }
      it { page.should have_css("#navbar a[href='#{register_path}']") }
    end

    context "events/index shows a link for anonymous to register" do
      before {
        Site.current.update_attributes(events_enabled: true)

        visit events_path
      }

      it { within('#content-wrapper') { page.should have_link(t('register.one'), register_path) } }
    end

    context "spaces/index shows a link for anonymous to register" do
      before { visit spaces_path }

      it { within('#content-wrapper') { page.should have_link(t('register.one'), register_path) } }
    end

    context "the home of a space shows a link for anonymous to register" do
      let(:space) { FactoryGirl.create(:space_with_associations, public: true) }
      before { visit space_path(space) }

      it { within('#content-wrapper') { page.should have_link(t('register.one'), register_path) } }
    end
  end

  context "when the flag is not set" do
    before { Site.current.update_attributes(registration_enabled: false) }

    context "shows links on the login page" do
      before { visit new_user_session_path }

      it { page.should_not have_content(t('devise.shared.links.register')) }
      it { page.should_not have_content(t('devise.shared.links.resend_confirmation_email')) }
      it { page.should_not have_css("#navbar a[href='#{register_path}']") }
    end

    context "events/index shows a link for anonymous to register" do
      before {
        Site.current.update_attributes(events_enabled: true)

        visit events_path
      }

      it { within('#content-wrapper') { page.should_not have_link(t('register.one'), register_path) } }
    end

    context "spaces/index shows a link for anonymous to register" do
      before { visit spaces_path }

      it { within('#content-wrapper') { page.should_not have_link(t('register.one'), register_path) } }
    end

    context "the home of a space shows a link for anonymous to register" do
      let(:space) { FactoryGirl.create(:space_with_associations, public: true) }
      before { visit space_path(space) }

      it { within('#content-wrapper') { page.should_not have_link(t('register.one'), register_path) } }
    end

  end
end
