require 'spec_helper'
require 'support/feature_helpers'

feature "Visitor in an event page" do

  before(:all) { Site.current.update_attributes(events_enabled: true) }

  shared_examples_for 'it can see event organizer options' do
    before {
      login_as(user)
      visit mweb_events.event_path(event)
    }

    subject { page }
    context 'inside event registration area' do
      it { should have_link(I18n.t('mweb_events.events.registration.invite_button'), :href => invite_event_path(event)) }
      it { should have_link(I18n.t('mweb_events.events.user_permissions.manage_organizers'), :href => user_permissions_event_path(event)) }
    end

    context 'in event footer' do
      subject { page.find('.event-footer') }

      it { should have_link(I18n.t('mweb_events.events.show.manage'), :href => mweb_events.event_participants_path(event)) }
      it { should have_link(I18n.t('_other.edit'), :href => mweb_events.edit_event_path(event)) }
    end
  end

  context 'in a public event owned by him' do
    let(:event) { FactoryGirl.create(:event, :owner => FactoryGirl.create(:user)) }
    let(:user) { event.owner }

    it_should_behave_like 'it can see event organizer options'
  end

  context "in an event where he's an organizer" do
    let(:event) { FactoryGirl.create(:event, owner: FactoryGirl.create(:user)) }
    let(:user) { FactoryGirl.create(:user) }
    before { event.add_organizer!(user) }

    it_should_behave_like 'it can see event organizer options'
  end

  context "in a space event where he's an organizer" do
    let(:event) { FactoryGirl.create(:event, owner: FactoryGirl.create(:space)) }
    let(:user) { FactoryGirl.create(:user) }
    before { event.add_organizer!(user) }

    it_should_behave_like 'it can see event organizer options'
  end

  context "in a space event where he's a space admin" do
    let(:event) { FactoryGirl.create(:event, owner: FactoryGirl.create(:space)) }
    let(:user) { FactoryGirl.create(:user) }
    before { event.owner.add_member!(user, 'Admin') }

    it_should_behave_like 'it can see event organizer options'
  end

end
