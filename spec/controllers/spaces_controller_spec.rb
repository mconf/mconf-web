# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe SpacesController do
  render_views

  describe "#index" do
    it "sets param[:view] to 'thumbnails' if not set"
    it "sets param[:view] to 'thumbnails' if different than 'list'"
    it "uses param[:view] as 'list' if already set to this value"
    # TODO: there's a lot more to test here

    context "if there's a user signed in" do

      context "assigns @user_spaces" do
        context "with the spaces the user belongs to" do
          let(:user) { FactoryGirl.create(:superuser) }
          before {
            s1 = FactoryGirl.create(:space)
            s2 = FactoryGirl.create(:space)
            s3 = FactoryGirl.create(:space)
            s1.add_member!(user, 'User')
            s2.add_member!(user, 'Admin')
            @user_spaces = [s1, s2]
          }
          before(:each) { sign_in(user) }

          it {
            get :index
            should assign_to(:user_spaces).with(@user_spaces)
          }
        end

        # bug #1166
        context "if there are no spaces registered, assigns with an ActiveRecord::Relation anyway" do
          let(:user) { FactoryGirl.create(:superuser) }
          before(:each) { sign_in(user) }

          before(:each) { get :index }
          it { should assign_to(:user_spaces).with([]) }
          it { assigns(:user_spaces).should be_an_instance_of(ActiveRecord::Relation) }
        end
      end

    end
  end

  it "#index.json"

  describe "#show" do
    let(:target) { FactoryGirl.create(:public_space) }
    let(:user) { FactoryGirl.create(:superuser) }
    before(:each) { sign_in(user) }

    it {
      get :show, :id => target.to_param
      should respond_with(:success)
    }

    context "layout and view" do
      before(:each) { get :show, :id => target.to_param }
      it { should render_template("spaces/show") }
      it { should render_with_layout("spaces_show") }
    end

    it "assigns @space"

    context "assigns @news_position" do
      before {
        n1 = FactoryGirl.create(:news, :space => target, :updated_at => DateTime.now - 1.day)
        n2 = FactoryGirl.create(:news, :space => target, :updated_at => DateTime.now)
      }

      context "with params[:news_position] if set" do
        before(:each) { get :show, :id => target.to_param, :news_position => "1" }
        it { should assign_to(:news_position).with(1) }
      end

      context "with 0 if params[:news_position] not set" do
        before(:each) { get :show, :id => target.to_param }
        it { should assign_to(:news_position).with(0) }
      end

      context "restricts to the amount of news existent" do
        before(:each) { get :show, :id => target.to_param, :news_position => "3" }
        it { should assign_to(:news_position).with(1) }
      end
    end

    context "assigns @news" do
      before {
        n1 = FactoryGirl.create(:news, :space => target, :updated_at => DateTime.now - 1.day)
        n2 = FactoryGirl.create(:news, :space => target, :updated_at => DateTime.now)
        n3 = FactoryGirl.create(:news, :space => target, :updated_at => DateTime.now - 2.days)
        @expected = [n2, n1, n3]
      }
      before(:each) { get :show, :id => target.to_param }
      it { should assign_to(:news).with(@expected) }
    end

    context "assigns @news_to_show" do
      before {
        n1 = FactoryGirl.create(:news, :space => target, :updated_at => DateTime.now - 1.day)
        n2 = FactoryGirl.create(:news, :space => target, :updated_at => DateTime.now)
        n3 = FactoryGirl.create(:news, :space => target, :updated_at => DateTime.now - 2.days)
        @expected = [n2, n1, n3]
      }

      context "when the target news exists" do
        before(:each) { get :show, :id => target.to_param, :news_position => "1" }
        it { should assign_to(:news_to_show).with(@expected[1]) }
      end

      context "when the target news doesn't exist" do
        before(:each) { get :show, :id => target.to_param, :news_position => "5" }
        it { should assign_to(:news_to_show).with(@expected[2]) }
      end

      context "set to nil when the space has no news" do
        before { News.destroy_all }
        before(:each) { get :show, :id => target.to_param }
        it { should assign_to(:news_to_show).with(nil) }
      end
    end

    context "assigns @latest_posts" do
      before {
        n1 = FactoryGirl.create(:post, :space => target, :updated_at => DateTime.now - 1.day)
        n2 = FactoryGirl.create(:post, :space => target, :updated_at => DateTime.now)
        n3 = FactoryGirl.create(:post, :space => target, :updated_at => DateTime.now - 2.days)
        n4 = FactoryGirl.create(:post, :space => target, :updated_at => DateTime.now - 3.days)
        @expected = [n2, n1, n3]
      }

      context "with the 3 latest posts" do
        before(:each) { get :show, :id => target.to_param }
        it { should assign_to(:latest_posts).with(@expected) }
      end

      it "ignoring posts with no parent"
      it "ignoring posts with a valid author"
      it "ignoring posts that are not related to events" # TODO: this can probably be removed
    end

    context "assigns @latest_users" do
      it "with the 3 latest members of the space"
      it "ignoring users that are nil" # TODO: review
    end

    context "assigns @upcoming_events" do
      it "with the 5 events that will happen in the future"
      it "ignoring events that already happened"
    end

    context "assigns @current_events" do
      it "with all the events that are hapenning now"
    end

    context "assigns @permission" do
      it "with the permission of the current user in the target space"
    end
  end

  describe "#show.json" do
    it "responds with the correct json"
  end

  describe "#new" do
    let(:user) { FactoryGirl.create(:superuser) }
    before(:each) { sign_in(user) }

    before(:each) { get :new }

    context "template and view" do
      it { should render_with_layout("application") }
      it { should render_template("spaces/new") }
    end

    it "assigns @space" do
      should assign_to(:space).with(instance_of(Space))
    end

    context "for @spaces_examples" do
      let(:do_action) { get :new }
      it_behaves_like "assigns @spaces_examples"
    end
  end

  describe "#create" do
    let(:user) { FactoryGirl.create(:superuser) }
    before(:each) { sign_in(user) }

    context "with valid attributes" do
      let(:space) { FactoryGirl.build(:space) }

      describe "creates the new space with the correct attributes" do
        before(:each) {
          expect {
            post :create, :space => space.attributes
          }.to change(Space, :count).by(1)
        }

        # TODO: for some reason the matcher is not found, maybe we just need to update rspec and other gems
        pending { Space.last.should have_same_attibutes_as(space) }
      end

      context "redirects to the new space" do
        before(:each) { post :create, :space => space.attributes }
        it { should redirect_to(space_path(Space.last)) }
      end

      describe "assigns @space with the new space" do
        before(:each) { post :create, :space => space.attributes }
        it { should assign_to(:space).with(Space.last) }
      end

      describe "sets the flash with a success message" do
        before(:each) { post :create, :space => space.attributes }
        it { should set_the_flash.to(I18n.t('space.created')) }
      end

      describe "adds the user as an admin in the space" do
        before(:each) { post :create, :space => space.attributes }
        it { Space.last.admins.should include(user) }
      end

      it "creates a new activity for the space created"
    end

    context "with invalid attributes" do
      let(:invalid_attributes) { FactoryGirl.attributes_for(:space, :name => nil) }

      it "assigns @space with the new space"

      describe "renders the view spaces/new with the correct layout" do
        before(:each) { post :create, :space => invalid_attributes }
        it { should render_with_layout("application") }
        it { should render_template("spaces/new") }
      end

      context do
        let(:do_action) { post :create, :space => invalid_attributes }
        it_behaves_like "assigns @spaces_examples"
      end

      it "does not create a new activity for the space that failed to be created"
    end
  end

  describe "#edit" do
    let(:space) { FactoryGirl.create(:space) }
    let(:user) { FactoryGirl.create(:superuser) }
    before(:each) { sign_in(user) }

    before(:each) { get :edit, :id => space.to_param }

    context "template and view" do
      it { should render_with_layout("spaces_show") }
      it { should render_template("spaces/edit") }
    end

    it "assigns @space" do
      should assign_to(:space).with(space)
    end
  end

  it "#update"
  it "#destroy"

  describe "#enable" do
    before(:each) { login_as(FactoryGirl.create(:superuser)) }

    context "loads the space by permalink" do
      let(:space) { FactoryGirl.create(:space) }
      before(:each) { post :enable, :id => space.to_param }
      it { assigns(:space).should eql(space) }
    end

    context "loads also spaces that are disabled" do
      let(:space) { FactoryGirl.create(:space, :disabled => true) }
      before(:each) { post :enable, :id => space.to_param }
      it { assigns(:space).should eql(space) }
    end

    context "if the space is already enabled" do
      let(:space) { FactoryGirl.create(:space, :disabled => false) }
      before(:each) { post :enable, :id => space.to_param }
      it { should redirect_to(manage_spaces_path) }
      it { should set_the_flash.to(I18n.t('space.error.enabled', :name => space.name)) }
    end

    context "if the space is disabled" do
      let(:space) { FactoryGirl.create(:space, :disabled => true) }
      before(:each) { post :enable, :id => space.to_param }
      it { should redirect_to(manage_spaces_path) }
      it { should set_the_flash.to(I18n.t('space.enabled')) }
      it { space.reload.disabled.should be_false }
    end
  end

  it "#leave"

  describe "#webconference" do
    let(:space) { FactoryGirl.create(:space) }
    let(:user) { FactoryGirl.create(:superuser) }
    before(:each) { sign_in(user) }

    before(:each) { get :webconference, :id => space.to_param }

    it { should render_template(:webconference) }
    it { should render_with_layout("spaces_show") }
    it { should assign_to(:space).with(space) }
    it { should assign_to(:webconf_room).with(space.bigbluebutton_room) }

    it "assigns @webconf_attendees with the attendees"
  end

  describe "#recordings" do
    let(:space) { FactoryGirl.create(:space) }
    let(:user) { FactoryGirl.create(:superuser) }
    before(:each) { login_as(user) }

    context "html full request" do
      before(:each) { get :recordings, :id => space.to_param }
      it { should render_template(:recordings) }
      it { should render_with_layout("spaces_show") }
      it { should assign_to(:webconf_room).with(space.bigbluebutton_room) }
      context "assigns @recordings" do
      end

      context "assigns @recordings" do
        context "doesn't include recordings from rooms of other owners" do
          before :each do
            FactoryGirl.create(:bigbluebutton_recording, :room => FactoryGirl.create(:bigbluebutton_room), :published => true)
          end
          it { should assign_to(:recordings).with([]) }
        end

        context "doesn't include recordings that are not published" do
          before :each do
            FactoryGirl.create(:bigbluebutton_recording, :room => space.bigbluebutton_room, :published => false)
          end
          it { should assign_to(:recordings).with([]) }
        end

        context "includes recordings that are not available" do
          before :each do
            @recording = FactoryGirl.create(:bigbluebutton_recording, :room => space.bigbluebutton_room, :published => true,
                                            :available => false)
          end
          it { should assign_to(:recordings).with([@recording]) }
        end

        context "order recordings by end_time DESC" do
          before :each do
            r1 = FactoryGirl.create(:bigbluebutton_recording, :room => space.bigbluebutton_room, :published => true,
                                    :end_time => DateTime.now)
            r2 = FactoryGirl.create(:bigbluebutton_recording, :room => space.bigbluebutton_room, :published => true,
                                    :end_time => DateTime.now - 2.days)
            r3 = FactoryGirl.create(:bigbluebutton_recording, :room => space.bigbluebutton_room, :published => true,
                                    :end_time => DateTime.now - 1.hour)
            @expected_recordings = [r1, r3, r2]
          end
          it { should assign_to(:recordings).with(@expected_recordings) }
        end
      end
    end

    context "if params[:limit] is set" do
      describe "limits the number of recordings assigned to @recordings" do
        before :each do
          @r1 = FactoryGirl.create(:bigbluebutton_recording, :room => space.bigbluebutton_room, :published => true,
                                   :end_time => DateTime.now)
          @r2 = FactoryGirl.create(:bigbluebutton_recording, :room => space.bigbluebutton_room, :published => true,
                                   :end_time => DateTime.now - 1.hour)
          @r3 = FactoryGirl.create(:bigbluebutton_recording, :room => space.bigbluebutton_room, :published => true,
                                   :end_time => DateTime.now - 2.hours)
          @r4 = FactoryGirl.create(:bigbluebutton_recording, :room => space.bigbluebutton_room, :published => true,
                                   :end_time => DateTime.now - 3.hours)
          @r5 = FactoryGirl.create(:bigbluebutton_recording, :room => space.bigbluebutton_room, :published => true,
                                   :end_time => DateTime.now - 4.hours)
        end
        before(:each) { get :recordings, :id => space.to_param, :limit => 3 }
        it { assigns(:recordings).count.should be(3) }
        it { assigns(:recordings).should include(@r1) }
        it { assigns(:recordings).should include(@r2) }
        it { assigns(:recordings).should include(@r3) }
      end
    end

    context "if params[:partial] is set" do
      before(:each) { get :recordings, :id => space.to_param, :partial => true }
      it { should render_template(:recordings) }
      it { should_not render_with_layout }
    end

  end

  describe "#recording_edit" do
    let(:user) { FactoryGirl.create(:user) }
    let(:space) { FactoryGirl.create(:space) }
    let(:recording) { FactoryGirl.create(:bigbluebutton_recording, :room => space.bigbluebutton_room) }
    before(:each) {
      space.add_member! user, "Admin"
      login_as(user)
    }

    context "html request" do
      before(:each) { get :edit_recording, :space_id => space.to_param, :id => recording.to_param }
      it { should render_template(:edit_recording) }
      it { should render_with_layout("spaces_show") }
      it { should assign_to(:space).with(space) }
      it { should assign_to(:recording).with(recording) }
      it { should assign_to(:webconf_room).with(space.bigbluebutton_room) }
      it { should assign_to(:redir_url).with(recordings_space_path(space.to_param)) }
    end

    context "xhr request" do
      before(:each) { xhr :get, :edit_recording, :space_id => space.to_param, :id => recording.to_param }
      it { should render_template(:edit_recording) }
      it { should_not render_with_layout }
    end
  end

  describe "#select" do
    context ".json" do
      let(:expected) {
        @spaces.map do |s|
          { :id => s.id, :permalink => s.permalink, :name => s.name,
            :public => s.public, :text => s.name, :url => space_url(s) }
        end
      }

      context "works" do
        before do
          10.times { FactoryGirl.create(:space) }
          @spaces = Space.all.first(5)
        end
        before(:each) { get :select, :format => :json }
        it { should respond_with(:success) }
        it { should respond_with_content_type(:json) }
        it { should assign_to(:spaces).with(@spaces) }
        it { response.body.should == expected.to_json }
      end

      context "matches spaces by name" do
        let(:unique_str) { "123" }
        before do
          FactoryGirl.create(:space, :name => "Yet Another Space")
          FactoryGirl.create(:space, :name => "Abc de Fgh")
          FactoryGirl.create(:space, :name => "Space #{unique_str} Cool") do |s|
            @spaces = [s]
          end
        end
        before(:each) { get :select, :q => unique_str, :format => :json }
        it { should assign_to(:spaces).with(@spaces) }
        it { response.body.should == expected.to_json }
      end

      context "has a param to limit the spaces in the response" do
        before do
          10.times { FactoryGirl.create(:space) }
        end
        before(:each) { get :select, :limit => 3, :format => :json }
        it { assigns(:spaces).count.should be(3) }
      end

      context "limits to 5 spaces by default" do
        before do
          10.times { FactoryGirl.create(:space) }
        end
        before(:each) { get :select, :format => :json }
        it { assigns(:spaces).count.should be(5) }
      end

      context "limits to a maximum of 50 spaces" do
        before do
          60.times { FactoryGirl.create(:space) }
        end
        before(:each) { get :select, :limit => 51, :format => :json }
        it { assigns(:spaces).count.should be(50) }
      end
    end
  end

  describe "abilities", :abilities => true do
    render_views(false)

    let(:hash) { { :id => target.to_param } }
    let(:attrs) { FactoryGirl.attributes_for(:space) }
    let(:hash_with_attrs) { hash.merge!(:space => attrs) }
    let(:hash_recording) { { :space_id => target.to_param, :id => recording.recordid } }

    context "for a superuser", :user => "superuser" do
      let(:user) { FactoryGirl.create(:superuser) }
      before(:each) { login_as(user) }

      it { should allow_access_to(:index) }
      it { should allow_access_to(:new) }
      it { should allow_access_to(:create).via(:post) }
      it { should allow_access_to(:select) }

      # the permissions are always the same, doesn't matter the type of room, so
      # we have them all in this common method
      shared_examples_for "a superuser accessing a webconf room in SpacesController" do
        it { should allow_access_to(:show, hash) }
        it { should allow_access_to(:edit, hash) }
        it { should allow_access_to(:user_permissions, hash) }
        it { should allow_access_to(:update, hash_with_attrs).via(:post) }
        it { should allow_access_to(:destroy, hash_with_attrs).via(:delete) }
        it { should allow_access_to(:enable, hash_with_attrs).via(:post) }
        it { should allow_access_to(:leave, hash_with_attrs).via(:post) }
        it { should allow_access_to(:webconference, hash) }
        it { should allow_access_to(:recordings, hash) }
        it { should allow_access_to(:edit_recording, hash_recording) }
      end

      context "in a public space" do
        let(:target) { FactoryGirl.create(:public_space) }
        let(:recording) { FactoryGirl.create(:bigbluebutton_recording, :room => target.bigbluebutton_room) }

        context "he is not a member of" do
          it_should_behave_like "a superuser accessing a webconf room in SpacesController"
        end

        context "he is a member of" do
          Space::USER_ROLES.each do |role|
            context "with the role '#{role}'" do
              before(:each) { target.add_member!(user, role) }
              it_should_behave_like "a superuser accessing a webconf room in SpacesController"
            end
          end
        end
      end

      context "in a private space" do
        let(:target) { FactoryGirl.create(:private_space) }
        let(:recording) { FactoryGirl.create(:bigbluebutton_recording, :room => target.bigbluebutton_room) }

        context "he is not a member of" do
          it_should_behave_like "a superuser accessing a webconf room in SpacesController"
        end

        context "he is a member of" do
          Space::USER_ROLES.each do |role|
            context "with the role '#{role}'" do
              before(:each) { target.add_member!(user, role) }
              it_should_behave_like "a superuser accessing a webconf room in SpacesController"
            end
          end
        end
      end

    end

    context "for a normal user", :user => "normal" do
      let(:user) { FactoryGirl.create(:user) }
      before(:each) { login_as(user) }

      it { should allow_access_to(:index) }
      it { should allow_access_to(:new) }
      it { should allow_access_to(:create).via(:post) }
      it { should allow_access_to(:select) }

      context "in a public space" do
        let(:target) { FactoryGirl.create(:public_space) }
        let(:recording) { FactoryGirl.create(:bigbluebutton_recording, :room => target.bigbluebutton_room) }

        context "he is not a member of" do
          it { should allow_access_to(:show, hash) }
          it { should_not allow_access_to(:edit, hash) }
          it { should_not allow_access_to(:user_permissions, hash) }
          it { should_not allow_access_to(:update, hash_with_attrs).via(:post) }
          it { should_not allow_access_to(:destroy, hash_with_attrs).via(:delete) }
          it { should_not allow_access_to(:enable, hash_with_attrs).via(:post) }
          it { should_not allow_access_to(:leave, hash_with_attrs).via(:post) }
          it { should allow_access_to(:webconference, hash) }
          it { should allow_access_to(:recordings, hash) }
        end

        context "he is a member of" do
          context "with the role 'Admin'" do
            before(:each) { target.add_member!(user, "Admin") }
            it { should allow_access_to(:show, hash) }
            it { should allow_access_to(:edit, hash) }
            it { should allow_access_to(:user_permissions, hash) }
            it { should allow_access_to(:update, hash_with_attrs).via(:post) }
            it { should allow_access_to(:destroy, hash_with_attrs).via(:delete) }
            it { should_not allow_access_to(:enable, hash_with_attrs).via(:post) }
            it { should allow_access_to(:leave, hash_with_attrs).via(:post) }
            it { should allow_access_to(:webconference, hash) }
            it { should allow_access_to(:recordings, hash) }
            it { should allow_access_to(:edit_recording, hash_recording) }
          end

          context "with the role 'User'" do
            before(:each) { target.add_member!(user, "User") }
            it { should allow_access_to(:show, hash) }
            it { should_not allow_access_to(:edit, hash) }
            it { should_not allow_access_to(:user_permissions, hash) }
            it { should_not allow_access_to(:update, hash_with_attrs).via(:post) }
            it { should_not allow_access_to(:destroy, hash_with_attrs).via(:delete) }
            it { should_not allow_access_to(:enable, hash_with_attrs).via(:post) }
            it { should allow_access_to(:leave, hash_with_attrs).via(:post) }
            it { should allow_access_to(:webconference, hash) }
            it { should allow_access_to(:recordings, hash) }
          end
        end
      end

      context "in a private space" do
        let(:target) { FactoryGirl.create(:private_space) }
        let(:recording) { FactoryGirl.create(:bigbluebutton_recording, :room => target.bigbluebutton_room) }

        context "he is not a member of" do
          it { should_not allow_access_to(:show, hash) }
          it { should_not allow_access_to(:update, hash_with_attrs).via(:post) }
          it { should_not allow_access_to(:destroy, hash_with_attrs).via(:delete) }
          it { should_not allow_access_to(:enable, hash_with_attrs).via(:post) }
          it { should_not allow_access_to(:leave, hash_with_attrs).via(:post) }
          it { should_not allow_access_to(:webconference, hash) }
          it { should_not allow_access_to(:recordings, hash) }
        end

        context "he is a member of" do
          context "with the role 'Admin'" do
            before(:each) { target.add_member!(user, "Admin") }
            it { should allow_access_to(:show, hash) }
            it { should allow_access_to(:edit, hash) }
            it { should allow_access_to(:user_permissions, hash) }
            it { should allow_access_to(:update, hash_with_attrs).via(:post) }
            it { should allow_access_to(:destroy, hash_with_attrs).via(:delete) }
            it { should_not allow_access_to(:enable, hash_with_attrs).via(:post) }
            it { should allow_access_to(:leave, hash_with_attrs).via(:post) }
            it { should allow_access_to(:webconference, hash) }
            it { should allow_access_to(:recordings, hash) }
            it { should allow_access_to(:edit_recording, hash_recording) }
          end

          context "with the role 'User'" do
            before(:each) { target.add_member!(user, "User") }
            it { should allow_access_to(:show, hash) }
            it { should_not allow_access_to(:edit, hash) }
            it { should_not allow_access_to(:user_permissions, hash) }
            it { should_not allow_access_to(:update, hash_with_attrs).via(:post) }
            it { should_not allow_access_to(:destroy, hash_with_attrs).via(:delete) }
            it { should_not allow_access_to(:enable, hash_with_attrs).via(:post) }
            it { should allow_access_to(:leave, hash_with_attrs).via(:post) }
            it { should allow_access_to(:webconference, hash) }
            it { should allow_access_to(:recordings, hash) }
          end
        end
      end

    end

    context "for an anonymous user", :user => "anonymous" do
      it { should allow_access_to(:index) }
      it { should require_authentication_for(:new) }
      it { should require_authentication_for(:create).via(:post) }
      it { should allow_access_to(:select) }

      context "in a public space" do
        let(:target) { FactoryGirl.create(:public_space) }
        it { should allow_access_to(:show, hash) }
        it { should_not allow_access_to(:edit, hash) }
        it { should_not allow_access_to(:user_permissions, hash) }
        it { should_not allow_access_to(:update, hash_with_attrs).via(:post) }
        it { should_not allow_access_to(:destroy, hash_with_attrs).via(:delete) }
        it { should_not allow_access_to(:enable, hash_with_attrs).via(:post) }
        it { should_not allow_access_to(:leave, hash_with_attrs).via(:post) }
        it { should allow_access_to(:webconference, hash) }
        it { should allow_access_to(:recordings, hash) }
      end

      context "in a private space" do
        let(:target) { FactoryGirl.create(:private_space) }
        it { should_not allow_access_to(:show, hash) }
        it { should_not allow_access_to(:edit, hash) }
        it { should_not allow_access_to(:user_permissions, hash) }
        it { should_not allow_access_to(:update, hash_with_attrs).via(:post) }
        it { should_not allow_access_to(:destroy, hash_with_attrs).via(:delete) }
        it { should_not allow_access_to(:enable, hash_with_attrs).via(:post) }
        it { should_not allow_access_to(:leave, hash_with_attrs).via(:post) }
        it { should_not allow_access_to(:webconference, hash) }
        it { should_not allow_access_to(:recordings, hash) }
      end
    end

  end

end
