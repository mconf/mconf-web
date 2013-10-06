# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe CustomBigbluebuttonRecordingsController do
  render_views

  describe "#update" do
    let(:recording) { FactoryGirl.create(:bigbluebutton_recording) }

    # This is an adapted copy of the same test done for this controller action in BigbluebuttonRails
    # we just check that the method 'permit' is being called with the correct parameters and assume
    # it does what it should.
    context "params handling" do
      let(:attrs) { FactoryGirl.attributes_for(:bigbluebutton_recording) }
      let(:params) { { :controller => 'CustomBigbluebuttonRoomsController', :action => :update, :bigbluebutton_recording => attrs } }

      context "for a superuser" do
        let(:user) { FactoryGirl.create(:superuser) }
        before(:each) { login_as(user) }

        let(:allowed_params) {
          [ :recordid, :meetingid, :name, :published, :start_time, :end_time, :available, :description ]
        }
        it {
          BigbluebuttonRecording.stub(:find_by_recordid).and_return(recording)
          recording.stub(:update_attributes).and_return(true)
          attrs.stub(:permit).and_return(attrs)
          controller.stub(:params).and_return(params)

          put :update, :id => recording.to_param, :bigbluebutton_recording => attrs
          attrs.should have_received(:permit).with(*allowed_params)
        }
      end

      context "for a normal user" do
        let(:user) { FactoryGirl.create(:user) }
        let(:recording) { FactoryGirl.create(:bigbluebutton_recording, :room => user.bigbluebutton_room) }
        before(:each) { login_as(user) }

        let(:allowed_params) {
          [ :description ]
        }
        it {
          BigbluebuttonRecording.stub(:find_by_recordid).and_return(recording)
          recording.stub(:update_attributes).and_return(true)
          attrs.stub(:permit).and_return(attrs)
          controller.stub(:params).and_return(params)

          put :update, :id => recording.to_param, :bigbluebutton_recording => attrs
          attrs.should have_received(:permit).with(*allowed_params)
        }
      end
    end
  end

  describe "abilities", :abilities => true do
    render_views(false)

    context "for a superuser", :user => "superuser" do
      let(:user) { FactoryGirl.create(:superuser) }
      let(:hash_with_server) { { :server_id => recording.server.id } }
      let(:hash) { hash_with_server.merge!(:id => recording.to_param) }
      before(:each) { login_as(user) }

      it { should allow_access_to(:index) }

      # the permissions are always the same, doesn't matter the type of recording, so
      # we have them all in this common method
      shared_examples_for "a superuser accessing any webconf recording" do
        it { should allow_access_to(:show, hash) }
        it { should allow_access_to(:edit, hash) }
        it { should allow_access_to(:update, hash).via(:put) }
        it { should allow_access_to(:destroy, hash).via(:delete) }
        it { should allow_access_to(:play, hash) }
        it { should allow_access_to(:publish, hash).via(:post) }
        it { should allow_access_to(:unpublish, hash).via(:post) }
      end

      context "in a recording of his room" do
        let(:recording) {
          room = user.bigbluebutton_room
          FactoryGirl.create(:bigbluebutton_recording, :room => room)
        }
        it_should_behave_like "a superuser accessing any webconf recording"
      end

      context "in a recording of another user's room" do
        let(:recording) {
          room = FactoryGirl.create(:superuser).bigbluebutton_room
          FactoryGirl.create(:bigbluebutton_recording, :room => room)
        }
        it_should_behave_like "a superuser accessing any webconf recording"
      end

      context "in a recording of a public space" do
        let(:space) { FactoryGirl.create(:space, :public => true) }
        let(:recording) {
          room = space.bigbluebutton_room
          FactoryGirl.create(:bigbluebutton_recording, :room => room)
        }

        context "he is a member of" do
          before { space.add_member!(user) }
          it_should_behave_like "a superuser accessing any webconf recording"
        end

        context "he is not a member of" do
          it_should_behave_like "a superuser accessing any webconf recording"
        end
      end

      context "in a recording of a private space" do
        let(:space) { FactoryGirl.create(:space, :public => false) }
        let(:recording) {
          room = space.bigbluebutton_room
          FactoryGirl.create(:bigbluebutton_recording, :room => room)
        }

        context "he is a member of" do
          before { space.add_member!(user) }
          it_should_behave_like "a superuser accessing any webconf recording"
        end

        context "he is not a member of" do
          it_should_behave_like "a superuser accessing any webconf recording"
        end
      end
    end

    context "for a normal user", :user => "normal" do
      let(:user) { FactoryGirl.create(:user) }
      let(:hash_with_server) { { :server_id => recording.server.id } }
      let(:hash) { hash_with_server.merge!(:id => recording.to_param) }
      before(:each) { login_as(user) }

      it { should_not allow_access_to(:index) }

      # most of the permissions are the same for any room
      shared_examples_for "a normal user accessing any webconf recording" do
        it { should_not allow_access_to(:destroy, hash).via(:delete) }
        it { should_not allow_access_to(:publish, hash).via(:post) }
        it { should_not allow_access_to(:unpublish, hash).via(:post) }
      end

      context "in a recording of his room" do
        let(:recording) {
          room = user.bigbluebutton_room
          FactoryGirl.create(:bigbluebutton_recording, :room => room)
        }
        it_should_behave_like "a normal user accessing any webconf recording"
        it { should allow_access_to(:play, hash) }
      end

      context "in a recording of another user's room" do
        let(:recording) {
          room = FactoryGirl.create(:user).bigbluebutton_room
          FactoryGirl.create(:bigbluebutton_recording, :room => room)
        }
        it_should_behave_like "a normal user accessing any webconf recording"
        it { should_not allow_access_to(:show, hash) }
        it { should_not allow_access_to(:play, hash) }
      end

      context "in a recording of a public space" do
        let(:space) { FactoryGirl.create(:space, :public => true) }
        let(:recording) {
          room = space.bigbluebutton_room
          FactoryGirl.create(:bigbluebutton_recording, :room => room)
        }

        context "he is a member of" do
          before { space.add_member!(user) }
          it_should_behave_like "a normal user accessing any webconf recording"
          it { should allow_access_to(:play, hash) }
        end

        context "he is not a member of" do
          it_should_behave_like "a normal user accessing any webconf recording"
          it { should allow_access_to(:play, hash) }
        end
      end

      context "in a recording of a private space" do
        let(:space) { FactoryGirl.create(:space, :public => false) }
        let(:recording) {
          room = space.bigbluebutton_room
          FactoryGirl.create(:bigbluebutton_recording, :room => room)
        }

        context "he is a member of" do
          before { space.add_member!(user) }
          it_should_behave_like "a normal user accessing any webconf recording"
          it { should allow_access_to(:play, hash) }
        end

        context "he is not a member of" do
          it_should_behave_like "a normal user accessing any webconf recording"
          it { should_not allow_access_to(:play, hash) }
        end
      end

    end

    context "for an anonymous user", :user => "anonymous" do
      let(:hash_with_server) { { :server_id => recording.server.id } }
      let(:hash) { hash_with_server.merge!(:id => recording.to_param) }

      it { should require_authentication_for(:index) }

      shared_examples_for "an anonymous user accessing any webconf recording" do
        it { should require_authentication_for(:show, hash) }
        it { should require_authentication_for(:edit, hash) }
        it { should require_authentication_for(:update, hash).via(:put) }
        it { should require_authentication_for(:destroy, hash).via(:delete) }
        it { should require_authentication_for(:play, hash) }
        it { should require_authentication_for(:publish, hash).via(:post) }
        it { should require_authentication_for(:unpublish, hash).via(:post) }
      end

      context "in a user room" do
        let(:recording) {
          room = FactoryGirl.create(:superuser).bigbluebutton_room
          FactoryGirl.create(:bigbluebutton_recording, :room => room)
        }
        it_should_behave_like "an anonymous user accessing any webconf recording"
      end

      context "in the room of public space" do
        let(:space) { FactoryGirl.create(:space, :public => true) }
        let(:recording) {
          room = space.bigbluebutton_room
          FactoryGirl.create(:bigbluebutton_recording, :room => room)
        }
        it_should_behave_like "an anonymous user accessing any webconf recording"
      end

      context "in the room of private space" do
        let(:space) { FactoryGirl.create(:space, :public => false) }
        let(:recording) {
          room = space.bigbluebutton_room
          FactoryGirl.create(:bigbluebutton_recording, :room => room)
        }
        it_should_behave_like "an anonymous user accessing any webconf recording"
      end
    end
  end
end
