# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'
require 'support/feature_helpers'

feature "Visitor in an event page" do

  before(:all) { Site.current.update_attributes(events_enabled: true) }

  let(:private_space) { FactoryGirl.create(:space, :public => false) }
  let(:private_event) { FactoryGirl.create(:event, :owner => private_space) }
  let(:public_event) { FactoryGirl.create(:event,
    :owner => FactoryGirl.create(:user),
    :social_networks => ['Facebook', 'Google Plus', 'Twitter'],
    :time_zone => Time.zone.name,
    :end_on => Time.zone.now + 1.day)
  }

  context 'in a public space' do

    before { visit event_path(public_event) }

    it { page.find('#page-header').should have_content(public_event.name) }
    it { page.find('#page-header').should have_content(public_event.owner.name) }
    it { page.find('.resource-visibility.public').should have_content(I18n.t('events.title.public')) }

    context 'inside event registration area' do
      subject { page.find('.event-registration .event-register') }
      it { should have_link(I18n.t('events.registration.button'), :href => new_event_participant_path(public_event)) }
      it { should have_css('.btn-success') }
    end

    context 'inside event description' do
      subject { page.find('.event-description') }
      it { should have_content(public_event.description) }
    end

    context 'inside event social media' do
      subject { page.find('.event-social-media') }
      it { should have_content('Facebook') }
      it { should have_content('Twitter') }
      it { should have_content('Google+') }
    end

    context 'inside event summary' do
      subject { page.find('.event-summary') }
      let!(:site_zone) { Time.zone }

      it { should have_content(public_event.summary) }

      it { should have_content(public_event.start_on.in_time_zone(site_zone).strftime("%A, %d %b %Y, %R")) }
      it { should have_content(public_event.end_on.in_time_zone(site_zone).strftime("%A, %d %b %Y, %R")) }

      it { should have_link(I18n.t('events.summary.calendar'),
        :href => event_path(public_event, :format => :ics)) }
    end
  end

  context 'in a public space with registrations closed' do

    before {
      public_event.update_attributes(start_on: Time.now - 1.day, end_on: Time.now - 5.minutes)
      visit event_path(public_event)
    }

    it { page.find('#page-header').should have_content(public_event.name) }
    it { page.find('#page-header').should have_content(public_event.owner.name) }
    it { page.find('.resource-visibility.public').should have_content(I18n.t('events.title.public')) }

    context 'inside event registration area' do
      subject { page.find('.event-registration .event-register') }
      it { should_not have_link(I18n.t('events.registration.button'), :href => new_event_participant_path(public_event)) }
      it { should_not have_css('.btn-success') }
      it { should have_content(I18n.t('events.registration.closed')) }
    end

  end

  context 'in a private space' do

    context 'header and private event icon' do
      before { visit event_path(private_event) }

      it { page.find('#page-header').should have_content(private_event.name) }
      it { page.find('#page-header').should have_content(private_event.owner.name) }
      it { page.find('.resource-visibility.private').should have_content(I18n.t('events.title.private')) }
    end

    context 'inside event registration area' do
      let(:user) { FactoryGirl.create(:user) }

      subject { page.find('.event-registration .event-register') }

      context 'with a logged out user' do
        before { visit event_path(private_event) }

        it { should_not have_content(I18n.t('events.registration.button')) }
        it { should_not have_link(I18n.t('events.registration.join_button'), href: new_space_join_request_path(private_event.owner)) }
        it { should_not have_css('.btn-success') }
        it { should have_content(I18n.t('events.registration.need_sign_in')) }
      end

      context 'with a logged in non member' do
        before {
          login_as(user)
          visit event_path(private_event)
        }

        it { should_not have_css("input[type='submit'][value='#{I18n.t('events.registration.button')}']") }
        it { should have_link(I18n.t('events.registration.join_button'), href: new_space_join_request_path(private_event.owner)) }
        it { should have_css('.btn-success') }
      end

      context 'with a logged in user member of the community' do
        before {
          login_as(user)
          private_space.add_member!(user)
          visit event_path(private_event)
        }

        it { should have_css("form[action='#{event_participants_path(private_event)}']") }
        it { should have_css("input[type='submit'][value='#{I18n.t('events.registration.button')}']") }
        it { should have_css('.btn-success') }
      end

    end


  end

end
