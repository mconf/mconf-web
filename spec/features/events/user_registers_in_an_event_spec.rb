# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'
require 'support/feature_helpers'

feature "User registers in an event" do

  before(:all) { Site.current.update_attributes(events_enabled: true) }
  subject { page }

  context 'as a logged in user clicking in the link to register' do
    let(:event) { FactoryGirl.create(:event, owner: FactoryGirl.create(:user)) }
    let(:user) { FactoryGirl.create(:user) }
    before {
      login_as(user, :scope => :user)
      visit mweb_events.event_path(event)
      click_button t("mweb_events.events.registration.button")
    }

    it { has_success_message t('mweb_events.participant.created') }
    it { current_path.should eq(mweb_events.event_path(event)) }
    it { should have_content t("mweb_events.events.registration.already_registered") }
    it { should have_content t("mweb_events.events.registration.unregister") }
    it { should_not have_content t("mweb_events.events.registration.button") }
    # updates the number of participants in the event
    # adds the user as a participant in the event

    context 'cancel registration after being registered' do
      before {
        click_link t("mweb_events.events.registration.unregister")
      }

      it { current_path.should eq(mweb_events.event_path(event)) }
      it { has_success_message t('mweb_events.participant.destroyed') }
      it { should_not have_content t("mweb_events.events.registration.unregister") }
    end
  end

  context "as a visitor clicking in the link to register" do
    let(:event) { FactoryGirl.create(:event, owner: FactoryGirl.create(:user)) }
    let(:user) { FactoryGirl.create(:user) }
    before {
      visit mweb_events.event_path(event)
      click_link t("mweb_events.events.registration.button")
    }

    it { current_path.should eq(mweb_events.new_event_participant_path(event)) }
    it { should have_content t("mweb_events.participants.split_form.annonymous_title") }
    it { should have_content t("mweb_events.participants.split_form.member_title") }

    context "register as annonymous" do
      let(:email) { 'cosmo@oot.ze' }
      before {
        fill_in "participant[email]", with: email
        click_button t('mweb_events.participants.form.submit')
      }

      it { has_success_message t('mweb_events.participants.create.waiting_confirmation') }
      it { current_path.should eq(mweb_events.event_path(event)) }
      it { should have_content t("mweb_events.events.registration.button") }
    end

    context "register as annonymous and confirms registration via email" do
      skip
    end

    context "register as annonymous and cancels registration via email" do
      skip
    end

    context "login then register as member" do
      before {
        user.update_attributes password: '123456', password_confirmation: '123456'
        fill_in "user[login]", with: user.permalink
        fill_in "user[password]", with: '123456'
        click_button t("sessions.login_form.login")
      }

      it { current_path.should eq(mweb_events.new_event_participant_path(event)) }
      it { should have_content(user.email) }
      it { should have_content t("mweb_events.participants.form.submit") }

      context "finish registering" do
        before { click_button t("mweb_events.participants.form.submit") }

        it { has_success_message t('mweb_events.participant.created') }
        it { current_path.should eq(mweb_events.event_path(event)) }
        it { should have_content t("mweb_events.events.registration.already_registered") }
        it { should have_content t("mweb_events.events.registration.unregister") }
        it { should_not have_content t("mweb_events.events.registration.button") }
      end
    end
  end

  scenario "for an event that already ended" do
    skip
    # shows a message saying that the event ended
    # doesn't show the register link
  end

  scenario "as a logged in user in an event of a private space the user is not a member of" do
    skip
    # shows a link for the user to join the space
    # doesn't show a link to register in the event
  end

  scenario "as a logged in user in an event of a private space the user is a member of" do
    skip
    # shows a link to register in the event
  end

  scenario "as a visitor in an event of a private space" do
    skip
    # shows a message saying that the user needs to sign in before registration
    # doesn't show a link to register in the event
  end
end
