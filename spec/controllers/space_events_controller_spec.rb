# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe SpaceEventsController do

  describe "#index" do
    let(:space) { FactoryGirl.create(:space) }
    let(:user) { FactoryGirl.create(:superuser) }
    before(:each) { sign_in(user) }

    context "layout and view" do
      before(:each) { get :index, :space_id => space.to_param }
      it { should render_template("events/index") }
      it { should render_with_layout("spaces_show") }
    end

    it "assigns @space"
    it "assigns @events"
    it "assigns @current_events"

    context "if params[:show] == 'past_events'" do
      it "assigns @past_events"
    end
    context "if params[:show] == 'upcoming_events'" do
      it "assigns @upcoming_events"
    end
    context "if params[:show] not set or invalid" do
      it "assigns @last_past_events"
      it "assigns @first_upcoming_events"
    end
  end

  describe "#index.atom" do
    it "returns an rss with all the events in the space"
  end

  describe "#show" do
    let(:space) { FactoryGirl.create(:space) }
    let(:event) { FactoryGirl.create(:event, :space => space) }
    let(:user) { FactoryGirl.create(:superuser) }
    before(:each) { sign_in(user) }

    context "layout and view" do
      before(:each) { get :show, :space_id => space.to_param, :id => event.to_param }
      it { should render_template("events/show") }
      it { should render_with_layout("spaces_show") }
    end

    it "assigns @space"
    it "assigns @event"
    it "assigns @webconf_room"
    it "assigns @attendees with the users that confirmed attendance"
    it "assigns @not_attendees with the users that confirmed that will not attend"
  end

  describe "#new" do
    let(:space) { FactoryGirl.create(:space) }
    let(:user) { FactoryGirl.create(:superuser) }
    before(:each) { sign_in(user) }

    context "layout and view" do
      before(:each) { get :new, :space_id => space.to_param }
      it { should render_template("events/new") }
      it { should render_with_layout("spaces_show") }
    end

    it "assigns @space"
    it "assigns @event"
    it "assigns @webconf_room"
  end

  describe "#create" do
    let(:space) { FactoryGirl.create(:space) }
    let(:user) { FactoryGirl.create(:superuser) }
    before(:each) { sign_in(user) }

    context "with valid attributes" do
      let(:event) { FactoryGirl.build(:event) }

      before(:each) {
        expect {
          post :create, :space_id => space.to_param, :event => event.attributes
        }.to change(Event, :count).by(1)
      }

      describe "creates the new event with the correct attributes" do
        # TODO: for some reason the matcher is not found, maybe we just need to update rspec and other gems
        pending { Event.last.should have_same_attibutes_as(event) }
      end

      it "redirects to the new event" do
        should redirect_to(space_event_path(space, Event.last))
      end

      it "assigns @event with the new event" do
        should assign_to(:event).with(Event.last)
      end

      it "assigns @space with the new event's space" do
        should assign_to(:space).with(Event.last.space)
      end

      it "sets the flash with a success message" do
        should set_the_flash.to(I18n.t('event.created'))
      end

      it "sets the current user as the author" do
        Event.last.author.should eq(user)
      end

      it "sets the event's space correctly" do
        Event.last.space.should eq(space)
      end

      it "assigns @webconf_room"
      it "creates a new activity for the event created"
    end

    context "with invalid attributes" do
      let(:invalid_attributes) { FactoryGirl.attributes_for(:event, :name => nil) }

      before(:each) { post :create, :space_id => space.to_param, :event => invalid_attributes }

      it "assigns @event with the new event"

      describe "renders the view events/new with the correct layout" do
        it { should render_template("events/new") }
        it { should render_with_layout("spaces_show") }
      end

      it "sets the flash with an error message"
      it "assigns @webconf_room"
      it "does not create a new activity for the event that failed to be created"
    end
  end

  describe "#edit" do
    let(:space) { FactoryGirl.create(:space) }
    let(:event) { FactoryGirl.create(:event, :space => space) }
    let(:user) { FactoryGirl.create(:superuser) }
    before(:each) { sign_in(user) }

    context "layout and view" do
      before(:each) { get :edit, :space_id => space.to_param, :id => event.to_param }
      it { should render_template("events/edit") }
      it { should render_with_layout("spaces_show") }
    end

    it "assigns @space"
    it "assigns @event"
    it "assigns @webconf_room"
  end

  describe "#update" do
    let(:space) { FactoryGirl.create(:space) }
    let(:event) { FactoryGirl.create(:event, :space => space) }
    let(:user) { FactoryGirl.create(:superuser) }
    before(:each) { sign_in(user) }

    context "with valid attributes" do
      let(:attributes) { FactoryGirl.attributes_for(:event) }

      before(:each) { put :update, :space_id => space.to_param, :id => event.to_param, :event => attributes }

      it "sets the correct attributes in the event"

      it "redirects to the event" do
        event.reload # because the event's id/permalink will change
        should redirect_to(space_event_path(space, event))
      end

      it "assigns @event with the event" do
        should assign_to(:event).with(event)
      end

      it "sets the flash with a success message" do
        should set_the_flash.to(I18n.t('event.updated'))
      end

      it "assigns @space with the event's space" do
        should assign_to(:space).with(event.space)
      end

      it "assigns @webconf_room"
      it "creates a new activity for the event updated"
    end

    context "with invalid attributes" do
      let(:invalid_attributes) { FactoryGirl.attributes_for(:event, :name => nil) }

      before(:each) { put :update, :space_id => space.to_param, :id => event.to_param, :event => invalid_attributes }

      it "assigns @event with the event"

      it "assigns @space with the event's space" do
        should assign_to(:space).with(event.space)
      end

      describe "renders the view events/edit with the correct layout" do
        it { should render_template("events/edit") }
        it { should render_with_layout("spaces_show") }
      end

      it "sets the flash with an error message"
      it "assigns @webconf_room"
      it "does not create a new activity for the event that failed to be updated"
    end
  end

  it "#destroy"

  describe "include SpamControllerModule" do
    it "#spam_report_create"
  end

  describe "abilities", :abilities => true do
    render_views(false)

    let(:attrs) { FactoryGirl.attributes_for(:event) }
    let(:hash) { { :space_id => target.space.to_param } }
    let(:hash_with_id) { hash.merge!(:id => target.to_param) }
    let(:hash_with_attrs) { hash_with_id.merge!(:event => attrs) }

    context "for a superuser", :user => "superuser" do
      let(:user) { FactoryGirl.create(:superuser) }
      before(:each) { login_as(user) }

      context "in a public space" do
        let(:space) { FactoryGirl.create(:public_space) }
        let(:target) { FactoryGirl.create(:event, :space => space) }

        context "he is not a member of" do
          it { should allow_access_to(:index, hash) }
          it { should allow_access_to(:new, hash) }
          it { should allow_access_to(:create, hash).via(:post) }
          it { should allow_access_to(:show, hash_with_id) }
          it { should allow_access_to(:edit, hash_with_id) }
          it { should allow_access_to(:update, hash_with_attrs).via(:post) }
          it { should allow_access_to(:destroy, hash_with_attrs).via(:delete) }
        end

        context "he is a member of" do
          Space::USER_ROLES.each do |role|
            context "with the role '#{role}'" do
              before(:each) { space.add_member!(user, role) }
              it { should allow_access_to(:index, hash) }
              it { should allow_access_to(:new, hash) }
              it { should allow_access_to(:create, hash).via(:post) }
              it { should allow_access_to(:show, hash_with_id) }
              it { should allow_access_to(:edit, hash_with_id) }
              it { should allow_access_to(:update, hash_with_attrs).via(:post) }
              it { should allow_access_to(:destroy, hash_with_attrs).via(:delete) }
            end
          end
        end
      end

      context "in a private space" do
        let(:space) { FactoryGirl.create(:private_space) }
        let(:target) { FactoryGirl.create(:event, :space => space) }

        context "he is not a member of" do
          it { should allow_access_to(:index, hash) }
          it { should allow_access_to(:new, hash) }
          it { should allow_access_to(:create, hash).via(:post) }
          it { should allow_access_to(:show, hash_with_id) }
          it { should allow_access_to(:edit, hash_with_id) }
          it { should allow_access_to(:update, hash_with_attrs).via(:post) }
          it { should allow_access_to(:destroy, hash_with_attrs).via(:delete) }
        end

        context "he is a member of" do
          Space::USER_ROLES.each do |role|
            context "with the role '#{role}'" do
              before(:each) { space.add_member!(user, role) }
              it { should allow_access_to(:index, hash) }
              it { should allow_access_to(:new, hash) }
              it { should allow_access_to(:create, hash).via(:post) }
              it { should allow_access_to(:show, hash_with_id) }
              it { should allow_access_to(:edit, hash_with_id) }
              it { should allow_access_to(:update, hash_with_attrs).via(:post) }
              it { should allow_access_to(:destroy, hash_with_attrs).via(:delete) }
            end
          end
        end
      end

    end

    context "for a normal user", :user => "normal" do
      let(:user) { FactoryGirl.create(:user) }
      before(:each) { login_as(user) }

      context "in a public space" do
        let(:space) { FactoryGirl.create(:public_space) }
        let(:target) { FactoryGirl.create(:event, :space => space) }

        context "he is not a member of" do
          it { should allow_access_to(:index, hash) }
          it { should_not allow_access_to(:new, hash) }
          it { should_not allow_access_to(:create, hash).via(:post) }
          it { should allow_access_to(:show, hash_with_id) }
          it { should_not allow_access_to(:edit, hash_with_id) }
          it { should_not allow_access_to(:update, hash_with_attrs).via(:post) }
          it { should_not allow_access_to(:destroy, hash_with_attrs).via(:delete) }
        end

        context "he is a member of" do
          Space::USER_ROLES.each do |role|
            context "with the role '#{role}'" do
              before(:each) { space.add_member!(user, role) }

              context "for an event he did not create" do
                it { should allow_access_to(:index, hash) }
                it { should allow_access_to(:new, hash) }
                it { should allow_access_to(:create, hash).via(:post) }
                it { should allow_access_to(:show, hash_with_id) }
                it { should_not allow_access_to(:edit, hash_with_id) }
                it { should_not allow_access_to(:update, hash_with_attrs).via(:post) }
                it { should_not allow_access_to(:destroy, hash_with_attrs).via(:delete) }
              end

              context "for an event he created" do
                let(:target) { FactoryGirl.create(:event, :space => space, :author => user) }

                it { should allow_access_to(:index, hash) }
                it { should allow_access_to(:new, hash) }
                it { should allow_access_to(:create, hash).via(:post) }
                it { should allow_access_to(:show, hash_with_id) }
                it { should allow_access_to(:edit, hash_with_id) }
                it { should allow_access_to(:update, hash_with_attrs).via(:post) }
                it { should allow_access_to(:destroy, hash_with_attrs).via(:delete) }
              end

            end
          end
        end
      end

      context "in a private space" do
        let(:space) { FactoryGirl.create(:private_space) }
        let(:target) { FactoryGirl.create(:event, :space => space) }

        context "he is not a member of" do
          it { should_not allow_access_to(:index, hash) }
          it { should_not allow_access_to(:new, hash) }
          it { should_not allow_access_to(:create, hash).via(:post) }
          it { should_not allow_access_to(:show, hash_with_id) }
          it { should_not allow_access_to(:edit, hash_with_id) }
          it { should_not allow_access_to(:update, hash_with_attrs).via(:post) }
          it { should_not allow_access_to(:destroy, hash_with_attrs).via(:delete) }
        end

        context "he is a member of" do
          Space::USER_ROLES.each do |role|
            context "with the role '#{role}'" do
              before(:each) { space.add_member!(user, role) }

              context "for an event he did not create" do
                it { should allow_access_to(:index, hash) }
                it { should allow_access_to(:new, hash) }
                it { should allow_access_to(:create, hash).via(:post) }
                it { should allow_access_to(:show, hash_with_id) }
                it { should_not allow_access_to(:edit, hash_with_id) }
                it { should_not allow_access_to(:update, hash_with_attrs).via(:post) }
                it { should_not allow_access_to(:destroy, hash_with_attrs).via(:delete) }
              end

              context "for an event he created" do
                let(:target) { FactoryGirl.create(:event, :space => space, :author => user) }

                it { should allow_access_to(:index, hash) }
                it { should allow_access_to(:new, hash) }
                it { should allow_access_to(:create, hash).via(:post) }
                it { should allow_access_to(:show, hash_with_id) }
                it { should allow_access_to(:edit, hash_with_id) }
                it { should allow_access_to(:update, hash_with_attrs).via(:post) }
                it { should allow_access_to(:destroy, hash_with_attrs).via(:delete) }
              end
            end
          end
        end
      end

    end

    context "for an anonymous user", :user => "anonymous" do

      context "in a public space" do
        let(:space) { FactoryGirl.create(:public_space) }
        let(:target) { FactoryGirl.create(:event, :space => space) }
        it { should allow_access_to(:index, hash) }
        it { should_not allow_access_to(:new, hash) }
        it { should_not allow_access_to(:create, hash).via(:post) }
        it { should allow_access_to(:show, hash_with_id) }
        it { should_not allow_access_to(:edit, hash_with_id) }
        it { should_not allow_access_to(:update, hash_with_attrs).via(:post) }
        it { should_not allow_access_to(:destroy, hash_with_attrs).via(:delete) }
      end

      context "in a private space" do
        let(:space) { FactoryGirl.create(:private_space) }
        let(:target) { FactoryGirl.create(:event, :space => space) }
        it { should_not allow_access_to(:index, hash) }
        it { should_not allow_access_to(:new, hash) }
        it { should_not allow_access_to(:create, hash).via(:post) }
        it { should_not allow_access_to(:show, hash_with_id) }
        it { should_not allow_access_to(:edit, hash_with_id) }
        it { should_not allow_access_to(:update, hash_with_attrs).via(:post) }
        it { should_not allow_access_to(:destroy, hash_with_attrs).via(:delete) }
      end
    end

  end

end
