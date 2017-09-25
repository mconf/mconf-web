# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe MyController do
  render_views

  it "#show"
  it "#activity"
  it "#rooms"
  it "#home"

  describe "#approval_pending" do
    context "html request" do
      before(:each) {
        request.env["HTTP_REFERER"] = root_url
        get :approval_pending
      }
      it { should respond_with(:success) }
      it { should render_template(:approval_pending) }
      it { should render_with_layout("navbar_bg") }
    end

    context "renders the page if the referer is /" do
      before(:each) {
        request.env["HTTP_REFERER"] = root_url
        get :approval_pending
      }
      it { should respond_with(:success) }
      it { should render_template(:approval_pending) }
    end

    context "renders the page if the referer is /register" do
      before(:each) {
        request.env["HTTP_REFERER"] = register_url
        get :approval_pending
      }
      it { should respond_with(:success) }
      it { should render_template(:approval_pending) }
    end

    context "renders the page if the referer is /login" do
      before(:each) {
        request.env["HTTP_REFERER"] = login_url
        get :approval_pending
      }
      it { should respond_with(:success) }
      it { should render_template(:approval_pending) }
    end

    context "renders the page if the referer is the shibboleth path" do
      before(:each) {
        request.env["HTTP_REFERER"] = shibboleth_url
        get :approval_pending
      }
      it { should respond_with(:success) }
      it { should render_template(:approval_pending) }
    end

    context "redirects to / if didn't come from one of the registration pages" do
      before(:each) {
        # don't set a referer, the same as the user typing the URL in the browser and
        # trying to access it
        get :approval_pending
      }
      it { should respond_with(:redirect) }
      it { should redirect_to(root_path) }
    end

    context "redirects to / if there's a user signed in" do
      before(:each) {
        sign_in(FactoryGirl.create(:user))
        request.env["HTTP_REFERER"] = root_url
        get :approval_pending
      }
      it { should respond_with(:redirect) }
      it { should redirect_to(root_path) }
    end
  end

  it "#activity"
  it "#rooms"

  describe "#meetings" do
    let(:user) { FactoryGirl.create(:user) }
    before(:each) { login_as(user) }

    context "html full request" do
      before(:each) { get :meetings, :recordedonly => 'false' }
      it { should render_template(:meetings) }
      it { should render_with_layout("application") }
      it { should assign_to(:room).with(user.bigbluebutton_room) }
      it "calls @room.get_meeting_info"

      context "assigns @meetings" do
        context "doesn't include meetings from rooms of other owners" do
          before :each do
            FactoryGirl.create(:bigbluebutton_meeting, :room => FactoryGirl.create(:bigbluebutton_room))
          end
          it { should assign_to(:meetings).with([]) }
        end

        context "includes meetings with recordings that are not published" do
          before :each do
            @meeting = FactoryGirl.create(:bigbluebutton_meeting, :room => user.bigbluebutton_room)
            FactoryGirl.create(:bigbluebutton_recording, :room => user.bigbluebutton_room, :published => false,
                                            :meeting => @meeting)
          end
          it { should assign_to(:meetings).with([@meeting]) }
        end

        context "includes meetings with recordings that are not available" do
          before :each do
            @meeting = FactoryGirl.create(:bigbluebutton_meeting, :room => user.bigbluebutton_room)
            FactoryGirl.create(:bigbluebutton_recording, :room => user.bigbluebutton_room, :published => true,
                                            :meeting => @meeting, :available => false)
          end
          it { should assign_to(:meetings).with([@meeting]) }
        end

        context "order meetings create_time DESC" do
          before :each do
            meeting1 = FactoryGirl.create(:bigbluebutton_meeting, :room => user.bigbluebutton_room,
                                          :create_time => DateTime.now)
            meeting2 = FactoryGirl.create(:bigbluebutton_meeting, :room => user.bigbluebutton_room,
                                          :create_time => DateTime.now - 2.days)
            meeting3 = FactoryGirl.create(:bigbluebutton_meeting, :room => user.bigbluebutton_room,
                                          :create_time => DateTime.now - 1.hour)
            @expected_meetings = [meeting1, meeting3, meeting2]
          end
          it { should assign_to(:meetings).with(@expected_meetings) }
        end
      end
    end

    context "if params[:limit] is set" do
      describe "limits the number of meetings assigned to @meetings" do
        before :each do
          @m1 = FactoryGirl.create(:bigbluebutton_meeting, :room => user.bigbluebutton_room,
                                   :create_time => DateTime.now)
          @m2 = FactoryGirl.create(:bigbluebutton_meeting, :room => user.bigbluebutton_room,
                                   :create_time => DateTime.now - 1.hour)
          @m3 = FactoryGirl.create(:bigbluebutton_meeting, :room => user.bigbluebutton_room,
                                   :create_time => DateTime.now - 2.hours)
          @m4 = FactoryGirl.create(:bigbluebutton_meeting, :room => user.bigbluebutton_room,
                                   :create_time => DateTime.now - 3.hours)
          @m5 = FactoryGirl.create(:bigbluebutton_meeting, :room => user.bigbluebutton_room,
                                   :create_time => DateTime.now - 4.hours)
        end
        before(:each) { get :meetings, :limit => 3, :recordedonly => 'false' }
        it { assigns(:meetings).count.should be(3) }
        it { assigns(:meetings).should include(@m1) }
        it { assigns(:meetings).should include(@m2) }
        it { assigns(:meetings).should include(@m3) }
      end
    end

    context "if recordedonly is not set or not false" do
      describe "show only meetings that have recordings" do
        let(:user) { FactoryGirl.create(:user) }
        before :each do
          @m1 = FactoryGirl.create(:bigbluebutton_meeting, :room => user.bigbluebutton_room,
                                   :create_time => DateTime.now, :recorded => true , :ended => true)
          @m2 = FactoryGirl.create(:bigbluebutton_meeting, :room => user.bigbluebutton_room,
                                   :create_time => DateTime.now - 1.hour, :recorded => true, :ended => true)
          @m3 = FactoryGirl.create(:bigbluebutton_meeting, :room => user.bigbluebutton_room,
                                   :create_time => DateTime.now - 2.hours)
          @r1 = FactoryGirl.create(:bigbluebutton_recording, :room => user.bigbluebutton_room,
                                   :meeting => @m1)
          @r2 = FactoryGirl.create(:bigbluebutton_recording, :room => user.bigbluebutton_room,
                                   :meeting => @m2)
        end
        before(:each) { get :meetings }
        it { assigns(:meetings).count.should be(2) }
        it { assigns(:meetings).should include(@m1) }
        it { assigns(:meetings).should include(@m2) }
        it { assigns(:meetings).should_not include(@m3) }
      end
    end
  end

  describe "#edit_recording" do
    let(:user) { FactoryGirl.create(:user) }
    let(:recording) { FactoryGirl.create(:bigbluebutton_recording, :room => user.bigbluebutton_room) }
    before(:each) { login_as(user) }

    context "xhr request" do
      before(:each) { xhr :get, :edit_recording, :id => recording.to_param }
      it { should render_template(:edit_recording) }
      it { should_not render_with_layout }
    end

    context "html request" do
      let(:do_action) { get :edit_recording, :id => recording.to_param }
      it_should_behave_like "an action that renders a modal - signed in"
    end
  end

  it "abilities"

end
