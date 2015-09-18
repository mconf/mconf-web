require 'spec_helper'

describe ParticipantsController do

  describe "#index" do
    let(:event) { FactoryGirl.create(:event) }

    context "layout and view" do
      before(:each) { get :index, :event_id => event.to_param }
      it { should render_template("mweb_events/participants/index") }
    end

    it "assigns @participants"
  end

  describe "#new" do
    let(:event) { FactoryGirl.create(:event) }

    context "layout and view" do
      before(:each) { get :new, :event_id => event.to_param }
      it { should render_template("mweb_events/participants/new") }
    end

    it "assigns @participant"
  end

  describe "#concat_datetimes"

  describe "#create" do
    let(:event) { FactoryGirl.create(:event) }

    context "creating with valid attributes" do
      let(:email) { Faker::Internet.email }
      before(:each) {

        expect {
          post :create, :event_id => event, :participant => FactoryGirl.attributes_for(:participant, :email => email)
        }.to change(Participant, :count).by(1)

      }

      it { redirect_to event_path(event) }

      it "sets the flash with a success message" do
        should set_the_flash.to(I18n.t('mweb_events.participant.created'))
      end

      it { Participant.last.email.should eql(email) }
      it { Participant.last.event.should eql(event) }
    end

    context "creating with invalid attributes" do
      before(:each) {
        expect {
          post :create, :event_id => event, :participant => FactoryGirl.attributes_for(:participant, :email => 'booboo')
        }.to change(Participant, :count).by(0)
      }

      it { should render_template("mweb_events/participants/new") }

      pending "sets the flash with an error message"

    end

    context "creating with a taken email" do
      let(:participant) { FactoryGirl.create(:participant, :event => event) }

      before(:each) {
        participant
        expect {
          post :create, :event_id => event, :participant => FactoryGirl.attributes_for(:participant, :email => participant.email)
        }.to change(Participant, :count).by(0)
      }

      it { redirect_to event_path(event) }

      it "sets the flash with an already registered success message" do
        should set_the_flash.to(I18n.t('mweb_events.participant.already_created'))
      end

    end

    context "creating two by email in the same event" do
      let(:email) { Faker::Internet.email }
      let(:email2) { Faker::Internet.email }
      let(:participant) { FactoryGirl.create(:participant, :owner => nil, :event => event, :email => email) }

      before(:each) {
        participant
        expect {
          post :create, :event_id => event.to_param, :participant => FactoryGirl.attributes_for(:participant, :email => email2)
        }.to change(Participant, :count).by(1)
      }

      it { redirect_to event_path(event) }
    end

  end

  describe "#destroy" do
    let(:participant) { FactoryGirl.create(:participant) }
    let(:owner) { participant.owner }
    let(:event) { participant.event }
    let(:event_owner) { event.owner }

    context "when is the participant's owner" do
      before(:each) {
        sign_in(owner)

        expect {
          delete :destroy, :id => participant.to_param, :event_id => event.to_param
        }.to change(Participant, :count).by(-1)

      }

      it { should redirect_to event_path(event) }

      it "sets the flash with a success message" do
        should set_the_flash.to(I18n.t('mweb_events.participant.destroyed'))
      end
    end

    context "when is the event's owner" do
      let(:referer) { '/any' }

      before(:each) {
        sign_in(event_owner)
        request.env["HTTP_REFERER"] = referer

        expect {
          delete :destroy, :id => participant.to_param, :event_id => event.to_param
        }.to change(Participant, :count).by(-1)

      }

      it { should redirect_to referer }

      it "sets the flash with a success message" do
        should set_the_flash.to(I18n.t('mweb_events.participant.destroyed'))
      end

    end

  end

  describe "abilities", :abilities => true do
  end

end