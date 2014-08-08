require 'spec_helper'
require 'support/feature_helpers'

feature "as a visitor" do

  before(:all) { Site.current.update_attributes(events_enabled: true) }

  context 'in a public space' do
    let(:private_space) { FactoryGirl.create(:space, :public => false) }
    let(:private_event) { FactoryGirl.create(:event, :owner => private_space) }

    let(:public_event) { FactoryGirl.create(:event,
      :owner => FactoryGirl.create(:user),
      :social_networks => ['Facebook', 'Google Plus', 'Twitter'],
      :time_zone => Time.zone.name,
      :end_on => Time.zone.now + 1.day)
    }

    before { visit mweb_events.event_path(public_event) }

    it { page.find('#page-header').should have_content(public_event.name) }
    it { page.find('.resource-visibility.public').should have_content(I18n.t('mweb_events.events.title.public')) }

    context 'inside event registration area' do
      subject { page.find('.event-registration .event-register') }
      it { should have_link(I18n.t('mweb_events.events.registration.button'), :href => mweb_events.new_event_participant_path(public_event)) }
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

      it { should have_link(I18n.t('mweb_events.events.summary.calendar'),
        :href => mweb_events.event_path(public_event, :format => :ics)) }
    end
  end

  scenario 'in a public space with registrations closed' do
  end

  scenario 'in a private space' do
  end

end