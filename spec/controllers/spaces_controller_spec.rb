# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe SpacesController do
  render_views

  it "includes Mconf::ApprovalControllerModule"

  describe "rescue_from exceptions" do
    context "rescues from CanCan::AccessDenied" do
      let(:space) { FactoryGirl.create(:space) }
      before { controller.stub(:authorize!) { raise CanCan::AccessDenied.new("Not authorized!", action, space) } }

      context "on #show" do
        let(:action) { :show }
        let(:do_action) { get :show, :id => space.to_param }
        include_examples "an action that rescues from CanCan::AccessDenied"
      end

      context "on #edit" do
        let(:action) { :edit }
        let(:do_action) { get :edit, :id => space.to_param }
        include_examples "an action that rescues from CanCan::AccessDenied"
      end

      context "on #update" do
        let(:action) { :update }
        let(:do_action) { put :update, :id => space.to_param, :space_attributes => FactoryGirl.attributes_for(:space) }
        include_examples "an action that does not rescue from CanCan::AccessDenied"
      end

      context "on #destroy" do
        let(:action) { :destroy }
        let(:do_action) { delete :destroy, :id => space.to_param }
        include_examples "an action that does not rescue from CanCan::AccessDenied"
      end

      # note: not testing all the other actions that do not rescue from CanCan::AccessDenied,
      #   just the two above

    end
  end

  describe "#index" do
    it "sets param[:view] to 'thumbnails' if not set"
    it "sets param[:view] to 'thumbnails' if different than 'list'"
    it "uses param[:view] as 'list' if set to this value"
    it "sets param[:order] to 'relevance' if not set"
    it "sets param[:order] to 'relevance' if different than 'abc'"
    it "uses param[:order] as 'abc' if set to this value"

    it { should_authorize Space, :index }

    context "orders by latest activities in the space" do
      let!(:now) { Time.now }
      let!(:spaces) {[
        FactoryGirl.create(:space_with_associations),
        FactoryGirl.create(:space_with_associations),
        FactoryGirl.create(:space_with_associations)
      ]}
      let!(:activities) {[
        # order: [1], [2], [0]
        RecentActivity.create(owner: spaces[0], created_at: now),
        RecentActivity.create(owner: spaces[1], created_at: now + 2.days),
        RecentActivity.create(owner: spaces[2], created_at: now + 1.day)
      ]}

      before { get :index }
      it { should assign_to(:spaces).with([spaces[1], spaces[2], spaces[0]]) }
    end

    it "orders by name if params[:order]=='abc'"
    it "returns only approved spaces"

    context "if there's a user signed in" do

      context "assigns @user_spaces" do
        context "with the spaces the user belongs to" do
          let(:user) { FactoryGirl.create(:superuser) }
          before {
            s1 = FactoryGirl.create(:space)
            s2 = FactoryGirl.create(:space)
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
          it { assigns(:user_spaces).should be_kind_of(ActiveRecord::Relation) }
        end
      end

    end
  end

  it "#index.json"

  describe "#show" do
    let(:target) { FactoryGirl.create(:space_with_associations, public: true) }
    let(:user) { FactoryGirl.create(:superuser) }
    before(:each) { sign_in(user) }

    it { should_authorize an_instance_of(Space), :show, :id => target.to_param }

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

    it { should_authorize an_instance_of(Space), :new }

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

    it { should_authorize an_instance_of(Space), :create, :via => :post, :space => {} }

    context "with valid attributes" do
      let(:space_attributes) { FactoryGirl.attributes_for(:space) }

      describe "creates the new space with the correct attributes" do
        before(:each) {
          expect {
            post :create, :space => space_attributes
          }.to change(Space, :count).by(1)
        }

        # TODO: for some reason the matcher is not found, maybe we just need to update rspec and other gems
        skip { Space.last.should have_same_attibutes_as(space) }
      end

      context "redirects to the new space" do
        before(:each) { post :create, :space => space_attributes }
        it { should redirect_to(space_path(Space.last)) }
      end

      describe "assigns @space with the new space" do
        before(:each) { post :create, :space => space_attributes }
        it { should assign_to(:space).with(Space.last) }
      end

      describe "sets the flash with a success message" do
        before(:each) { post :create, :space => space_attributes }
        it { should set_flash.to(I18n.t('space.created')) }
      end

      describe "adds the user as an admin in the space" do
        before(:each) { post :create, :space => space_attributes }
        it { Space.last.admins.should include(user) }
      end

      describe "creates a new activity for the space created" do
        before(:each) {
          expect {
            post :create, :space => space_attributes
          }.to change(RecentActivity, :count).by(1)
        }
        it { RecentActivity.last.trackable.should eq(Space.last) }
        it { RecentActivity.last.owner.should eq(Space.last) }
        it { RecentActivity.last.parameters[:username].should eq(user.full_name) }
        it { RecentActivity.last.recipient.should eq(user) }
      end

      it "automatically approves the space if it's an admin creating it"
      it "shows the correct message if the space is approved"
      it "shows the correct message if the space is not approved yet"
    end

    context "with invalid attributes" do
      let(:invalid_attributes) { FactoryGirl.attributes_for(:space, :name => nil) }

      describe "assigns @space with the new space" do
        before(:each) { post :create, :space => invalid_attributes }
        # TODO: maybe we could be more specific here
        it { should assign_to(:space).with_kind_of(Space) }
      end

      describe "renders the view spaces/new with the correct layout" do
        before(:each) { post :create, :space => invalid_attributes }
        it { should render_with_layout("application") }
        it { should render_template("spaces/new") }
      end

      context do
        let(:do_action) { post :create, :space => invalid_attributes }
        it_behaves_like "assigns @spaces_examples"
      end

      describe "does not create a new activity for the space that failed to be created" do
        let(:does_not_create_activity) {
          expect {
            post :create, :space => invalid_attributes
          }.to change(RecentActivity, :count).by(0)
        }
        it { does_not_create_activity }
      end

    end
  end

  describe "#edit" do
    let(:space) { FactoryGirl.create(:space_with_associations) }
    let(:user) { FactoryGirl.create(:superuser) }
    before(:each) { sign_in(user) }

    it { should_authorize an_instance_of(Space), :edit, :id => space.to_param }

    before(:each) { get :edit, :id => space.to_param }

    context "template and view" do
      it { should render_with_layout("spaces_show") }
      it { should render_template("spaces/edit") }
    end

    it "assigns @space" do
      should assign_to(:space).with(space)
    end
  end

  describe "#update" do
    let(:space) { FactoryGirl.create(:space) }
    let(:user) { FactoryGirl.create(:superuser) }
    let(:referer) { "/any" }
    before do
      sign_in(user)
      request.env["HTTP_REFERER"] = referer
    end

    context "params_handling" do
      let(:space_attributes) { FactoryGirl.attributes_for(:space) }
      let(:params) {
        {
          :id => space.permalink,
          :controller => "spaces",
          :action => "update",
          :space => space_attributes
        }
      }

      let(:space_allowed_params) {
        [ :name, :description, :logo_image, :public, :permalink, :disabled,
          :repository, :crop_x, :crop_y, :crop_w, :crop_h, :crop_img_w, :crop_img_h,
          :bigbluebutton_room_attributes =>
            [ :id, :attendee_key, :moderator_key, :default_layout, :private, :welcome_msg ]
        ]
      }
      before {
        space_attributes.stub(:permit).and_return(space_attributes)
        controller.stub(:params).and_return(params)
      }
      before(:each) {
        expect {
          put :update, :id => space.to_param, :space => space_attributes
        }.to change { RecentActivity.count }.by(1)
      }
      it { space_attributes.should have_received(:permit).with(*space_allowed_params) }
      it { should redirect_to(referer) }
      it { should set_flash.to(I18n.t("flash.spaces.update.notice")) }
    end

    context "changing no parameters" do
      before(:each) {
        expect {
          put :update, :id => space.to_param, :space => {}
        }.not_to change { RecentActivity.count }
      }

      it { should redirect_to(referer) }
      it { should set_flash.to(I18n.t("flash.spaces.update.notice")) }
    end

    context "changing some parameters" do
      let(:space_params) { {name: "#{space.name}_new", description: "#{space.description} new" } }
      before(:each) {
        expect {
          put :update, :id => space.to_param, :space => space_params
        }.to change {RecentActivity.count}.by(1)
      }

      it { RecentActivity.last.key.should eq('space.update') }
      it { RecentActivity.last.parameters[:changed_attributes].should eq(['name', 'description']) }
      it { should redirect_to(referer) }
      it { should set_flash.to(I18n.t("flash.spaces.update.notice")) }
    end

    context "changing the logo_image parameter" do
      let(:space_params) { { space: {}, format: 'json', id: space.to_param, uploaded_file: Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/files/test-logo.png'))) } }

      before(:each) {
        expect {
          post :update_logo, space_params
        }.to change {RecentActivity.count}.by(1)
      }

      it { RecentActivity.last.key.should eq('space.update') }
      it { RecentActivity.last.parameters[:changed_attributes].should eq(['logo_image']) }
    end
  end

  describe "#destroy" do
    let(:space) { FactoryGirl.create(:space) }
    subject { delete :destroy, :id => space.to_param}

    context "superusers can destroy spaces" do
      before(:each) do
        login_as(FactoryGirl.create(:superuser))
        space
      end

      it { expect {subject}.to change(Space, :count).by(-1)}
      it { should redirect_to(manage_spaces_path) }
    end

    context "admins of a space can't destroy the space" do
      before(:each) do
        user = FactoryGirl.create(:user)
        login_as(user)
        space.add_member!(user, 'Admin')
      end

      it { expect{subject}.to raise_error(CanCan::AccessDenied) }
    end

  end

  describe "#disable" do
    let(:space) { FactoryGirl.create(:space) }
    subject { delete :disable, :id => space.to_param }

    context "superusers can disable spaces" do
      before(:each) do
        request.env['HTTP_REFERER'] = manage_spaces_path
        login_as(FactoryGirl.create(:superuser))
        space
      end

      it { expect{subject}.to change(Space, :count).by(-1)}
      it {
        subject
        space.reload.disabled.should be_truthy
      }
      it { should redirect_to(manage_spaces_path) }
    end

    context "admins of the space can disable the space" do
      before(:each) do
        user = FactoryGirl.create(:user)
        space.add_member!(user, 'Admin')
        login_as(user)
      end

      it { expect{subject}.to change(Space, :count).by(-1) }
      it {
        subject
        space.reload.disabled.should be_truthy
      }
      it { should redirect_to(spaces_path) }
    end

    it "normal users can't disable a space"
    it "space members can't disable a space"
  end

  describe "#enable" do
    before(:each) {
      request.env["HTTP_REFERER"] = manage_spaces_path
      login_as(FactoryGirl.create(:superuser))
    }

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
      it { should set_flash.to(I18n.t('flash.spaces.enable.failure', :name => space.name)) }
    end

    context "if the space is disabled" do
      let(:space) { FactoryGirl.create(:space, :disabled => true) }
      before(:each) { post :enable, :id => space.to_param }
      it { should redirect_to(manage_spaces_path) }
      it { should set_flash.to(I18n.t('flash.spaces.enable.notice')) }
      it { space.reload.disabled.should be_falsey }
    end
  end



  it "#leave"

  describe "#webconference" do
    let!(:space) { FactoryGirl.create(:space_with_associations, public: true) }
    let!(:user) { FactoryGirl.create(:superuser) }

    context "normal testing" do
      before(:each) {
        sign_in(user)
        get :webconference, :id => space.to_param
      }

      it { should render_template(:webconference) }
      it { should render_with_layout("spaces_show") }
      it { should assign_to(:space).with(space) }
      it { should assign_to(:webconf_room).with(space.bigbluebutton_room) }
    end

    context "assigns @webconf_attendees" do

      context "when there are attendees" do
        let!(:user2) { FactoryGirl.create(:user) }
        let(:attendee1) {
          attendee = BigbluebuttonAttendee.new
          attendee.user_id = user.id
          attendee.full_name = user.username
          attendee.role = :attendee
          attendee
        }
        let(:attendee2) {
          attendee = BigbluebuttonAttendee.new
          attendee.user_id = user2.id
          attendee.full_name = user2.username
          attendee.role = :moderator
          attendee
        }
        before(:each) {
          BigbluebuttonRoom.any_instance.stub(:attendees).and_return([attendee1, attendee2])
          get :webconference, :id => space.to_param
        }
        it { should assign_to(:webconf_attendees).with([user, user2]) }
      end

      context "when there are no attendees" do
        before(:each) {
          BigbluebuttonRoom.any_instance.stub(:attendees).and_return([])
          get :webconference, :id => space.to_param
        }
        it { should assign_to(:webconf_attendees).with([]) }
      end

      context "doesn't replicate users" do
        let(:attendee1) {
          attendee = BigbluebuttonAttendee.new
          attendee.user_id = user.id
          attendee.full_name = user.username
          attendee.role = :attendee
          attendee
        }
        let(:attendee2) {
          attendee = BigbluebuttonAttendee.new
          attendee.user_id = user.id
          attendee.full_name = user.username
          attendee.role = :moderator
          attendee
        }
        before(:each) {
          BigbluebuttonRoom.any_instance.stub(:attendees).and_return([attendee1, attendee2])
          get :webconference, :id => space.to_param
        }
        it { should assign_to(:webconf_attendees).with([user]) }
      end

      context "ignores users that are not registered" do
        let(:attendee1) {
          attendee = BigbluebuttonAttendee.new
          attendee.user_id = user.id
          attendee.full_name = user.username
          attendee.role = :attendee
          attendee
        }
        let(:attendee2) {
          attendee = BigbluebuttonAttendee.new
          attendee.user_id = "anything-invalid"
          attendee.full_name = "Invited User"
          attendee.role = :moderator
          attendee
        }
        before(:each) {
          BigbluebuttonRoom.any_instance.stub(:attendees).and_return([attendee1, attendee2])
          get :webconference, :id => space.to_param
        }
        it { should assign_to(:webconf_attendees).with([user]) }
      end
    end
  end

  describe "#recordings" do
    let(:space) { FactoryGirl.create(:space_with_associations) }
    let(:user) { FactoryGirl.create(:user, superuser: true) }
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
    let(:space) { FactoryGirl.create(:space_with_associations) }
    let(:recording) { FactoryGirl.create(:bigbluebutton_recording, :room => space.bigbluebutton_room) }

    it { should_authorize space, :edit_recording, space_id: space.to_param, id: recording.to_param }

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

    it { should_authorize Space, :select }

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

  describe "#user_permission" do
    let(:target) { FactoryGirl.create(:space_with_associations) }
    let(:user) { FactoryGirl.create(:superuser) }
    before(:each) { sign_in(user) }

    it { should_authorize an_instance_of(Space), :user_permissions, :id => target.to_param }

    context "layout and view" do
      before(:each) { get :user_permissions, :id => target.to_param }

      it { should respond_with(:success) }
      it { assigns(:space).should eq(target) }
      it { should render_template(/user_permissions/) }
      it { should render_with_layout("spaces_show") }
    end

    context "user is not a member of the space" do
      let(:user) { FactoryGirl.create(:user) }

      it { expect { get :user_permissions, :id => target.to_param }.to raise_error(CanCan::AccessDenied) }
    end

    context "user is a normal member of the space" do
      let(:user) { FactoryGirl.create(:user) }
      before(:each) {
        target.add_member!(user)
      }

      it { expect { get :user_permissions, :id => target.to_param }.to raise_error(CanCan::AccessDenied) }
    end

    context "user is admin of the space" do
      let(:user) { FactoryGirl.create(:user) }
      before(:each) {
        target.add_member!(user, 'Admin')
        get :user_permissions, :id => target.to_param
      }

      it { should respond_with(:success) }
    end
  end
end
