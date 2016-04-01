# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe EventsController do
  render_views

  describe "#index" do
    context "layout and view" do
      context 'with no events' do
        before { get :index }

        it { should redirect_to events_path(:show => 'all') }
        it { assigns(:events).with([]) }
      end

      context 'with no upcoming events' do
        before {
          t = Time.zone.now
          @events = [
            FactoryGirl.create(:event, :start_on => t - 3.day, :end_on => t - 1.day),
            FactoryGirl.create(:event, :start_on => t - 2.day, :end_on => t - 1.day),
            FactoryGirl.create(:event, :start_on => t - 1.day, :end_on => t - 1.hour)
          ]

          get :index
        }

        it { should redirect_to events_path(:show => 'all') }
        it { assigns(:events).with(@events) }
      end

      context 'with upcoming events' do
        before {
          t = Time.zone.now
          @events = [
            FactoryGirl.create(:event, :start_on => t - 3.day, :end_on => t - 1.day),
            FactoryGirl.create(:event, :start_on => t + 1.day, :end_on => t + 10.day),
          ]

          get :index
        }

        it { should render_template("events/index") }
        it { assigns(:events).with([@events[1]]) }
      end
    end

    context "if params[:show]" do
      let(:zone) { Time.zone.name }
      let(:now) { Time.zone.now }
      let!(:e1) { FactoryGirl.create(:event, :time_zone => zone, :start_on => now - 4.hour, :end_on => now - 2.hour) }
      let!(:e2) { FactoryGirl.create(:event, :time_zone => zone, :start_on => now - 3.hour, :end_on => now - 1.hour) }
      let!(:e3) { FactoryGirl.create(:event, :time_zone => zone, :start_on => now - 2.hour, :end_on => now + 5.minute) }
      let!(:e4) { FactoryGirl.create(:event, :time_zone => zone, :start_on => now - 1.hour, :end_on => now + 10.minute) }
      let!(:e5) { FactoryGirl.create(:event, :time_zone => zone, :start_on => now + 1.hour, :end_on => now + 2.hour) }
      let!(:e6) { FactoryGirl.create(:event, :time_zone => zone, :start_on => now + 2.hour, :end_on => now + 3.hour) }

      context "is 'past_events'" do
        before(:each) { get :index, :show => 'past_events' }

        it { assigns(:events).should eq([e2, e1]) }
      end

      context "is 'upcoming_events'" do
        before(:each) { get :index, :show => 'upcoming_events' }

        it { assigns(:events).should eq([e3, e4, e5, e6]) }
      end

      context "is not present acts like 'upcoming_events'" do
        before(:each) { get :index }

        it { assigns(:events).should eq([e3, e4, e5, e6]) }
      end

      context "is 'happening_now'" do
        before(:each) { get :index, :show => 'happening_now' }

        it { assigns(:events).should eq([e3, e4]) }
      end

      context "is 'all'" do
        before(:each) { get :index, :show => 'all' }

        it { assigns(:events).should eq([e6, e5, e4, e3, e2, e1]) }
      end
    end

    context "if params[:q] is present" do
      let!(:e1) { FactoryGirl.create(:event, :name => 'Party Hard') }
      let!(:e2) { FactoryGirl.create(:event, :name => 'Party Soft') }

      context "find all" do
        before(:each) { get :index, :q => 'Party' }

        it { assigns(:events).should include(e1, e2) }
      end

      context "find one" do
        before(:each) { get :index, :q => 'hard' }

        it { assigns(:events).should include(e1) }
      end

      context "find nothing" do
        before(:each) { get :index, :q => 'Stay home and rest' }

        it { assigns(:events).should eq([]) }
      end

      context "find nothing with empty query" do
        before(:each) { get :index, :q => '' }

        # SQL query actually finds all the records...
        # Is the empty query desired behavior? Lets leave this here for now
        skip { assigns(:events).should eq([]) }
      end

    end
  end

  describe "disabled owners" do
    let!(:event) { FactoryGirl.create(:event, owner: owner) }
    before { event.owner.disable }

    context "dont index events with disabled owners" do
      before {
        1.upto(3) { FactoryGirl.create(:event) }
        get :index
      }

      context 'that are users' do
        let(:owner) { FactoryGirl.create(:user) }

        it { assigns(:events).size.should be(3) }
        it { assigns(:events).should_not include(event) }
      end

      context 'that are spaces' do
        let(:owner) { FactoryGirl.create(:space) }

        it { assigns(:events).size.should be(3) }
        it { assigns(:events).should_not include(event) }
      end
    end

    context 'dont show events with disabled owners (not found in database)' do
      context 'that are users' do
        let(:owner) { FactoryGirl.create(:user) }

        it { expect { get :show, id: event.to_param }.to raise_error(ActiveRecord::RecordNotFound) }
      end

      context 'that are spaces' do
        let(:owner) { FactoryGirl.create(:space) }

        it { expect { get :show, id: event.to_param }.to raise_error(ActiveRecord::RecordNotFound) }
      end
    end

  end

  describe "unapproved owners" do
    let!(:event) { FactoryGirl.create(:event, owner: owner) }
    before { event.owner.disapprove! }

    context "dont index events with unapproved owners" do
      before {
        1.upto(3) { FactoryGirl.create(:event) }
        get :index
      }

      context 'that are users' do
        let(:owner) { FactoryGirl.create(:user) }

        it { assigns(:events).size.should be(3) }
        it { assigns(:events).should_not include(event) }
      end

      context 'that are spaces' do
        let(:owner) { FactoryGirl.create(:space) }

        it { assigns(:events).size.should be(3) }
        it { assigns(:events).should_not include(event) }
      end
    end

    context 'dont show events with unapproved owners' do
      context 'that are users' do
        let(:owner) { FactoryGirl.create(:user) }

        it { expect { get :show, id: event.to_param }.to raise_error(CanCan::AccessDenied) }
      end

      context 'that are spaces' do
        let(:owner) { FactoryGirl.create(:space) }

        it { expect { get :show, id: event.to_param }.to raise_error(CanCan::AccessDenied) }
      end
    end


  end

  describe "#index.atom" do
    it "returns an rss with all the events available"
  end

  describe "#show.atom" do
    it "returns an rss with all the updates in the event"
  end

  describe "#select" do

    it { should_authorize Event, :select }

    it "event public: [true, false] with space owned events"

    context ".json" do
      let(:expected) {
        @events.map do |e|
          { :id => e.id, :permalink => e.permalink, :public => true,
            :name => e.name, :text => e.name, :url => event_url(e) }
        end
      }

      context "works" do
        before do
          10.times { FactoryGirl.create(:event) }
          @events = Event.all.first(5)
        end
        before(:each) { get :select, :format => :json }
        it { should respond_with(:success) }
        it { should respond_with_content_type(:json) }
        it { should assign_to(:events).with(@events) }
        it { response.body.should == expected.to_json }
      end

      context "matches events by name" do
        let(:unique_str) { "EVENNNT" }
        before do
          FactoryGirl.create(:event, :name => "A cool event")
          FactoryGirl.create(:event, :name => "A random event")
          FactoryGirl.create(:event, :name => "Event #{unique_str} dude") do |e|
            @events = [e]
          end
        end
        before(:each) { get :select, :q => unique_str, :format => :json }
        it { should assign_to(:events).with(@events) }
        it { response.body.should == expected.to_json }
      end

      context "has a param to limit the events in the response" do
        before do
          10.times { FactoryGirl.create(:event) }
        end
        before(:each) { get :select, :limit => 3, :format => :json }
        it { assigns(:events).count.should be(3) }
      end

      context "limits to 5 events by default" do
        before do
          10.times { FactoryGirl.create(:event) }
        end
        before(:each) { get :select, :format => :json }
        it { assigns(:events).count.should be(5) }
      end

      context "limits to a maximum of 50 events" do
        before do
          60.times { FactoryGirl.create(:event) }
        end
        before(:each) { get :select, :limit => 51, :format => :json }
        it { assigns(:events).count.should be(50) }
      end
    end
  end

  describe "#show" do
    let(:event) { FactoryGirl.create(:event, owner: FactoryGirl.create(:user)) }
    before(:each) { get :show, :id => event.to_param }

    context "layout and view" do
      it { should render_template("events/show") }
    end

    it { assigns(:event).should eq(event) }
  end

  describe "#new" do
    let(:user) { FactoryGirl.create(:user) }
    let(:owner) { user }
    before(:each) { sign_in(owner) }

    context "layout and view" do
      before { get :new }
      it { should render_template("events/new") }
    end

    it { assigns(:event) }

    context 'events belonging to spaces' do
      let(:space) { FactoryGirl.create(:space) }

      context "tries to access new/event page with 'space_id' as a bad value" do
        subject { lambda { get :new, space_id: "#{space.to_param}-baaaaaad" } }
        it { should raise_exception(ActiveRecord::RecordNotFound) }
      end

      context "tries to access new/event page in a space which he's not a member" do
        before { get :new, space_id: space.to_param }

        it { should redirect_to(events_path) }
        it { should set_flash.to(I18n.t('flash.events.create.error')) }
      end

      context "tries to access new/event page in a space which is disabled" do
        before { get :new, space_id: space.to_param }

        it { should redirect_to(events_path) }
        it { should set_flash.to(I18n.t('flash.events.create.error')) }
      end

      context "tries to access new/event page in a space which is not approved" do
        before { get :new, space_id: space.to_param }

        it { should redirect_to(events_path) }
        it { should set_flash.to(I18n.t('flash.events.create.error')) }
      end

      context "tries to access new/event page in a space which he's a member" do
        before {
          space.add_member!(user)
          get :new, space_id: space.to_param
        }

        it { should render_template("events/new") }
      end

      context "tries to access new/event page in a space which is disabled" do
        subject {
          lambda {
            space.add_member!(user)
            space.update_attribute(:disabled, true)
            get :new, space_id: space.to_param
          }
        }

        it { should raise_exception(ActiveRecord::RecordNotFound) }
      end

      context "tries to access new/event page in a space which is not approved" do
        before {
          space.add_member!(user)
          space.update_attribute(:approved, false)
          get :new, space_id: space.to_param
        }

        it { should redirect_to(events_path) }
        it { should set_flash.to(I18n.t('flash.events.create.error')) }
      end

    end

  end

  describe "#create" do
    let(:user) { FactoryGirl.create(:user) }
    let(:owner) { user }
    before(:each) { sign_in(owner) }

    context "with valid attributes" do
      let!(:attributes) { FactoryGirl.attributes_for(:event) }

      before(:each) {
        expect {
          post :create, :event => attributes
        }.to change(Event, :count).by(1)
      }

      it "redirects to the new event" do
        should redirect_to(event_path(Event.last))
      end

      it "assigns @event with the new event" do
        assigns(:event).should eq(Event.last)
      end

      it "sets the flash with a success message" do
        should set_flash.to(I18n.t('flash.events.create.notice'))
      end

      it "sets the current user as the owner" do
        Event.last.owner.should eq(owner)
      end
    end

    context 'events belonging to spaces' do
      let(:space) { FactoryGirl.create(:space) }
      let!(:attributes) { FactoryGirl.attributes_for(:event) }

      context "tries to create event with 'owner_id' as a bad value" do
        before {
          expect {
            post :create, event: attributes.merge(owner_type: "Space", owner_id: "#{space.id}-2baaaad")
            }.to change { Event.count }.by(0)
        }

        it { should set_flash.to(I18n.t('flash.events.create.error')) }
      end

      context "tries to create event with 'owner_type' as a bad value" do
        before {
          expect {
            post :create, event: attributes.merge(owner_type: "space-bad", owner_id: space.id)
           }.to change { Event.count }.by(0)
        }

        it { should render_template('events/new') }
      end

      context "tries to create event in a space which he's not a member" do
        before { post :create, event: attributes.merge(owner_type: "Space", owner_id: space.id) }

        it { should redirect_to(events_path) }
        it { should set_flash.to(I18n.t('flash.events.create.error')) }
      end

      context "tries to create event in a space which is disabled" do
        before { post :create, event: attributes.merge(owner_type: "Space", owner_id: space.id) }

        it { should redirect_to(events_path) }
        it { should set_flash.to(I18n.t('flash.events.create.error')) }
      end

      context "tries to create event in a space which is not approved" do
        before { post :create, event: attributes.merge(owner_type: "Space", owner_id: space.id) }

        it { should redirect_to(events_path) }
        it { should set_flash.to(I18n.t('flash.events.create.error')) }
      end

      context "tries to create event page in a space which he's a member" do
        before {
          expect {
            space.add_member!(user)
            post :create, event: attributes.merge(owner_type: "Space", owner_id: space.id)
          }.to change {space.events.count}.by(1)
        }

        it { should redirect_to(event_path(Event.last)) }
      end

    end

    context "with empty time_zone" do
      let!(:attributes) { FactoryGirl.attributes_for(:event, time_zone: '') }

      before(:each) {
        expect { post :create, :event => attributes }.to change(Event, :count).by(1)
      }

      it { should redirect_to(event_path(Event.last)) }
      it { assigns(:event).should eq(Event.last) }
      it { should set_flash.to(I18n.t('flash.events.create.notice')) }
      it { Event.last.time_zone.should eq(Time.zone.name) }
    end

    context "with invalid attributes" do
      let(:invalid_attributes) { FactoryGirl.attributes_for(:event, :name => nil) }

      before(:each) {
        expect { post :create, :event => invalid_attributes }.to change(Event, :count).by(0)
      }

      describe "renders the view events/new with the correct layout" do
        it { should render_template("events/new") }
      end
    end
  end

  describe "#edit" do
    let(:event) { FactoryGirl.create(:event, owner: owner) }
    let(:owner) { FactoryGirl.create(:user) }
    before(:each) {
      sign_in(owner)
      get :edit, :id => event.to_param
    }

    context "layout and view" do
      it { should render_template("events/edit") }
    end

    it "assigns @event with the event" do
      assigns(:event).should eq(event)
    end
  end

  describe "#update" do
    let(:event) { FactoryGirl.create(:event, owner: owner) }
    let(:owner) { FactoryGirl.create(:user) }
    before(:each) {
      sign_in(owner)
      put :update, :id => event, event: attributes
    }

    context "with valid attributes" do
      let(:attributes) { {name: "#{event.name} New name"} }

      it "sets the correct attributes in the event"

      it "redirects to the event" do
        should redirect_to(event_path(event))
      end

      it "assigns @event with the event" do
        assigns(:event).should eq(event)
      end

      it "sets the flash with a success message" do
        should set_flash.to(I18n.t('flash.events.update.notice'))
      end
    end

    context "with empty time_zone" do
      let(:event) { FactoryGirl.create(:event, owner: owner, time_zone: 'American Samoa') }
      let(:attributes) { {time_zone: ''} }

      it { should redirect_to(event_path(event)) }
      it { assigns(:event).should eq(event) }
      it { should set_flash.to(I18n.t('flash.events.update.notice')) }
      it { event.reload.time_zone.should eq(Time.zone.name) }
    end

    context "with invalid attributes" do
      let(:attributes) { FactoryGirl.attributes_for(:event, :name => nil) }

      it "assigns @event with the event"

      describe "renders the view events/edit with the correct layout" do
        it { should render_template("events/edit") }
      end

      skip 'it has errors on the invalid fields (feature test)'
    end
  end

  it "#destroy"

  describe "abilities", :abilities => true do
  end

  describe "#show" do
    before(:all) { Site.current.update_attributes(events_enabled: true) }

    context "logged as a normal user" do
      let(:user) { FactoryGirl.create(:user) }

      before(:each) { login_as(user) }

      context "event owner is a disabled space" do
        let(:owner) { FactoryGirl.create(:space) }
        let(:event) { FactoryGirl.create(:event, owner: owner) }

        before { owner.disable }

        it { expect { get :show, id: event.to_param }.to raise_error(ActiveRecord::RecordNotFound) }
      end

      context "event owner is a disabled user" do
        let(:owner) { FactoryGirl.create(:user) }
        let(:event) { FactoryGirl.create(:event, owner: owner) }

        before { owner.disable }

        it { expect { get :show, id: event.to_param }.to raise_error(ActiveRecord::RecordNotFound) }
      end
    end

    context "logged as an admin" do
      let(:admin) { FactoryGirl.create(:superuser) }

      before(:each) { login_as(admin) }

      context "event owner is a disabled space" do
        let(:owner) { FactoryGirl.create(:space) }
        let(:event) { FactoryGirl.create(:event, owner: owner) }

        before { owner.disable }

        it { expect { get :show, id: event.to_param }.not_to raise_error }
      end

      context "event owner is a disabled user" do
        let(:owner) { FactoryGirl.create(:user) }
        let(:event) { FactoryGirl.create(:event, owner: owner) }

        before { owner.disable }

        it { expect { get :show, id: event.to_param }.not_to raise_error }
      end
    end

  end

  describe "#invite" do
    let(:owner) { FactoryGirl.create(:user) }
    let(:event) { FactoryGirl.create(:event, owner: owner) }

    context "template and layout" do
      context "template" do
        before(:each) { login_as(owner) }

        context "xhr" do
          before { xhr :get, :invite, id: event.to_param }

          it { should render_template(:invite) }
          it { should_not render_with_layout }
          it { should assign_to(:event).with(event) }
        end

        context "normal request" do
          before { get :invite, id: event.to_param }

          it { should render_template(:invite) }
          it { should assign_to(:event).with(event) }
        end
      end
    end

    context 'authorization' do
      let(:subject) {
        login_as(logged_user)
        get :invite, id: event.to_param
      }

      context 'should not authorize non managers to invite' do
        let(:logged_user) { FactoryGirl.create(:user) }
        it { expect{subject}.to raise_error(CanCan::AccessDenied) }
      end

      context 'should authorize owner of a space to invite' do
        let(:logged_user) { event.owner }
        it { expect{subject}.not_to raise_error }
      end
    end

    it { should_authorize an_instance_of(Event), :invite, method: :get, id: event.to_param }
  end

  describe "#send_invitation" do
    let!(:referer) { "/any" }
    let(:event) { FactoryGirl.create(:event, owner: FactoryGirl.create(:user)) }
    let(:users) { [FactoryGirl.create(:user)] }
    let(:title) { 'Title' }
    let(:message) { 'Message' }
    let(:success) { I18n.t('events.send_invitation.success') + ' ' + users.map(&:name).join(', ')}
    let(:error) { I18n.t('events.send_invitation.errors') + ' ' + users.map(&:name).join(', ') }
    before { request.env["HTTP_REFERER"] = referer }

    context "sending the form" do
      let!(:hash) { { users: users.map(&:id).join(','),
         title: title,
         message: message} }
      before {
        login_as(event.owner)
      }

      context "with correct data" do
        before {
          expect {
            post :send_invitation, invite: hash, id: event.to_param
          }.to change { Invitation.count }.by(1)
        }
        context "with the right type set" do
          it { Invitation.last.class.should be(EventInvitation) }
        end
        it { should redirect_to(referer) }
        it { should set_flash.to success }
      end

      context "with more than one user invited" do
        let(:users) { [FactoryGirl.create(:user), FactoryGirl.create(:user)] }
        before {
          expect {
            post :send_invitation, invite: hash, id: event.to_param
          }.to change { Invitation.count }.by(users.length)
        }

        context "with the right type set" do
          it { Invitation.last.class.should be(EventInvitation) }
        end

        it { should redirect_to(referer) }
        it { should set_flash.to success }
      end

      context "missing users" do
        before {
          hash.delete(:users)
          expect {
            post :send_invitation, invite: hash, id: event.to_param
          }.not_to change { Invitation.count }
        }
        it { should redirect_to(referer) }
        it { should set_flash.to I18n.t('events.send_invitation.blank_users') }
      end

      context "missing the title" do
        let(:title) { nil }
        before {
          expect {
            post :send_invitation, invite: hash, id: event.to_param
          }.not_to change { Invitation.count }
        }
        it { should redirect_to(referer) }
        it { should set_flash.to I18n.t('events.send_invitation.error_title') }
      end

      context "missing the users" do
        let(:users) { [] }
        before {
          expect {
            post :send_invitation, invite: hash, id: event.to_param
          }.not_to change { Invitation.count }
        }
        it { should redirect_to(referer) }
        skip { should set_flash.to error }
      end

      context "missing the message" do
        let(:message) { nil }
        before {
          expect {
            post :send_invitation, invite: hash, id: event.to_param
          }.to change { Invitation.count }.by(1)
        }

        context "with the right type set" do
          it { Invitation.last.class.should be(EventInvitation) }
        end

        it { should redirect_to(referer) }
        it { should set_flash.to success }
      end
    end

    context 'authorization' do
      let(:subject) {
        login_as(logged_user)
        post :send_invitation, id: event.to_param, invite: {}
      }

      context 'should not authorize non managers to send invites' do
        let(:logged_user) { FactoryGirl.create(:user) }
        it { expect{subject}.to raise_error(CanCan::AccessDenied) }
      end

      context 'should authorize owner of a space to send invites' do
        let(:logged_user) { event.owner }
        it { expect{subject}.not_to raise_error }
      end
    end

    it { should_authorize an_instance_of(Event), :send_invitation, id: event.to_param }
  end

end
