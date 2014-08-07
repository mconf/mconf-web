require 'spec_helper'
require 'support/feature_helpers'

feature "as a visitor" do
  let(:private_space) { FactoryGirl.create(:space, :public => false) }
  let(:private_event) { FactoryGirl.create(:event, :owner => private_space) }

  let(:public_event) { FactoryGirl.create(:event,
    :owner => FactoryGirl.create(:user),
    :social_networks => ['Facebook', 'Google Plus', 'Twitter'],
    :time_zone => Time.zone.name,
    :end_on => Time.zone.now + 1.day)
  }

  scenario 'in a public space' do
    visit mweb_events.event_path(public_event)

    within('#page-header') do
      expect(page).to have_content(public_event.name)

      within('.resource-visibility.public') do
        expect(page).to have_content(I18n.t('mweb_events.events.title.public'))
      end
    end

    within('.event-registration .event-register') do
      expect(page).to have_link(I18n.t('mweb_events.events.registration.button'),
        :href => mweb_events.new_event_participant_path(public_event)
      )

      expect(page).to have_css('.btn-success')
    end

    within('.event-description') do
      expect(page).to have_content(public_event.description)
    end

    within('.event-social-media') do
      expect(page).to have_content('Facebook')
      expect(page).to have_content('Twitter')
      expect(page).to have_content('Google+')
    end

    within('.event-summary') do
      site_zone = Time.zone

      expect(page).to have_content(public_event.summary)

      expect(page).to have_content(public_event.start_on.in_time_zone(site_zone).strftime("%A, %d %b %Y, %R"))
      expect(page).to have_content(public_event.end_on.in_time_zone(site_zone).strftime("%A, %d %b %Y, %R"))

      expect(page).to have_link(I18n.t('mweb_events.events.summary.calendar'),
        :href => mweb_events.event_path(public_event, :format => :ics))
    end
  end

  scenario 'in a public space with registrations closed' do
  end

  scenario 'in a private space' do
  end

end