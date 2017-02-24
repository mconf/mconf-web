require 'spec_helper'

describe ParticipantsController do

  before { Site.current.update_attributes events_enabled: true }

  describe "#index" do
    let(:event_owner) { FactoryGirl.create(:user) }
    let(:event) { FactoryGirl.create(:event, owner: event_owner) }

    context "layout and view" do

      context 'for a logged out user' do

        it {
          expect {
            get :index, :event_id => event.to_param
          }.to raise_error(CanCan::AccessDenied)
        }
      end

      context "for a logged in user who's not the event's creator" do
        before(:each) {
          sign_in(FactoryGirl.create(:user))
          get :index, :event_id => event.to_param
        }

        it { should render_template("participants/index") }
        it { assigns(:participants) }
      end

      context "for the event's creator" do
        before(:each) {
          sign_in(event_owner)
          get :index, :event_id => event.to_param
        }

        it { should render_template("participants/index") }
        it { assigns(:participants) }
        it { assigns(:participants).should eq(event.participants) }

        context "with some participants for the event" do
          let!(:participant1) { FactoryGirl.create(:participant, event: event) }
          let!(:participant2) { FactoryGirl.create(:participant, event: event) }

          it { assigns(:participants).should include(participant1, participant2) }
          it { assigns(:participants).size.should be(2) }
        end
      end

    end

  end

  describe "#new" do
    let(:event) { FactoryGirl.create(:event) }

    context "layout and view" do
      before(:each) { get :new, :event_id => event.to_param }
      it { should render_template("participants/new") }
      it { assigns(:participant) }
    end

  end

  describe "#concat_datetimes"

  describe "#create" do
    let(:event) { FactoryGirl.create(:event) }

    context "creating with valid attributes and logged in user" do
      let(:user) { FactoryGirl.create(:user) }

      before(:each) {

        expect {
          PublicActivity.with_tracking do
            sign_in(user)
            post :create, :event_id => event, :participant => FactoryGirl.attributes_for(:participant)
          end
        }.to change(Participant, :count).by(1)

      }

      it { redirect_to event_path(event) }

      it "sets the flash with a success message" do
        should set_flash.to(I18n.t('flash.participants.create.notice'))
      end

      it { Participant.last.email.should eql(user.email) }
      it { Participant.last.owner.should eql(user) }
      it { Participant.last.event.should eql(event) }
      it { RecentActivity.last.trackable.should eq(Participant.last) }
      skip { RecentActivity.last.recipient.should eq(user) }
      skip { RecentActivity.last.owner.should eq(event) }
    end

    context "creating with valid attributes but no logged in user" do
      let(:email) { Forgery::Internet.email_address }
      before(:each) {

        expect {
          PublicActivity.with_tracking do
            post :create, :event_id => event, :participant => FactoryGirl.attributes_for(:participant, :email => email)
          end
        }.to change(Participant, :count).by(1)

      }

      it { redirect_to event_path(event) }

      it "sets the flash with a success message" do
        should set_flash.to(I18n.t('flash.participants.create.waiting_confirmation'))
      end

      it { Participant.last.email.should eql(email) }
      it { Participant.last.event.should eql(event) }
      it { RecentActivity.last.trackable.should eq(Participant.last) }
    end

    context "creating with invalid attributes" do
      before(:each) {
        expect {
          post :create, :event_id => event, :participant => FactoryGirl.attributes_for(:participant, :email => 'booboo')
        }.to change(Participant, :count).by(0)
      }

      it { should render_template("participants/new") }

      it { should set_flash.to(I18n.t('flash.participants.create.alert')) }

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
        should set_flash.to(I18n.t('flash.participants.create.already_created'))
      end

    end

    context "creating two by email in the same event" do
      let(:email) { Forgery::Internet.email_address }
      let(:email2) { Forgery::Internet.email_address }
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
        should set_flash.to(I18n.t('flash.participants.destroy.notice'))
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
        should set_flash.to(I18n.t('flash.participants.destroy.notice'))
      end

    end

  end

  describe "abilities", :abilities => true do
  end

  describe "events module" do
    let(:user) { FactoryGirl.create(:superuser) }
    let(:participant_attributes) { FactoryGirl.attributes_for(:participant) }
    let(:participant) { FactoryGirl.create(:participant) }
    let(:participant_id) { participant.to_param }
    let(:event) { participant.event }
    let(:event_id) { event.to_param }

    context "disabled" do
      before(:each) {
        Site.current.update_attribute(:events_enabled, false)
        login_as(user)
      }
      it { expect { get :index, event_id: event_id }.to raise_error(ActionController::RoutingError) }
      it { expect { post :create, event_id: event_id, participant: participant_attributes }.to raise_error(ActionController::RoutingError) }
      it { expect { get :new, event_id: event_id }.to raise_error(ActionController::RoutingError) }
      it { expect { patch :update, event_id: event_id, id: participant_id, participant: participant_attributes }.to raise_error(ActionController::RoutingError) }
      it { expect { put :update, event_id: event_id, id: participant_id, participant: participant_attributes }.to raise_error(ActionController::RoutingError) }
      it { expect { request.env["HTTP_REFERER"] = "/any"
                    delete :destroy, event_id: event_id, id: participant_id, participant: participant_attributes}.to raise_error(ActionController::RoutingError) }
    end

    context "enabled" do
      before(:each) {
        Site.current.update_attribute(:events_enabled, true)
        login_as(user)
      }
      it { expect { get :index, event_id: event_id }.not_to raise_error }
      it { expect { post :create, event_id: event_id, participant: participant_attributes }.not_to raise_error }
      it { expect { get :new, event_id: event_id }.not_to raise_error }
      it { expect { patch :update, event_id: event_id, id: participant_id, participant: participant_attributes }.not_to raise_error }
      it { expect { put :update, event_id: event_id, id: participant_id, participant: participant_attributes }.not_to raise_error }
      it { expect { request.env["HTTP_REFERER"] = "/any"
                    delete :destroy, event_id: event_id, id: participant_id, participant: participant_attributes }.not_to raise_error }
    end
  end

end
