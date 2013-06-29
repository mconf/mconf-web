# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe CustomBigbluebuttonRoomsController do
  render_views

  context "checks access permissions for" do
    render_views false

    context "a superuser" do
      let(:user) { FactoryGirl.create(:superuser) }
      let(:hash_with_server) { { :server_id => room.server.id } }
      let(:hash) { hash_with_server.merge!(:id => room.to_param) }
      before(:each) { login_as(user) }

      it { should_not deny_access_to(:index) }
      it { should_not deny_access_to(:new) }
      it { should_not deny_access_to(:create).via(:post) }

      # the permissions are always the same, doesn't matter the type of room, so
      # we have them all in this common method
      shared_examples_for "a superuser accessing any webconf room" do
        it { should_not deny_access_to(:show, hash) }
        it { should_not deny_access_to(:edit, hash) }
        it { should_not deny_access_to(:update, hash).via(:put) }
        it { should_not deny_access_to(:destroy, hash).via(:delete) }
        it { should_not deny_access_to(:join, hash) }
        it { should_not deny_access_to(:auth, hash).via(:post) }
        it { should_not deny_access_to(:invite, hash) }
        it { should_not deny_access_to(:external, hash_with_server) }
        it { should_not deny_access_to(:external_auth, hash_with_server).via(:post) }
        it { should_not deny_access_to(:end, hash) }
        it { should_not deny_access_to(:join_mobile, hash) }
        it { should_not deny_access_to(:running, hash) }
      end

      context "in his room" do
        let(:room) { user.bigbluebutton_room }
        it_should_behave_like "a superuser accessing any webconf room"
      end

      context "in another user's room" do
        let(:room) { FactoryGirl.create(:superuser).bigbluebutton_room }
        it_should_behave_like "a superuser accessing any webconf room"
      end

      context "in the room of public space" do
        let(:space) { FactoryGirl.create(:space, :public => true) }
        let(:room) { space.bigbluebutton_room }

        context "he is a member of" do
          before { space.add_member!(user) }
          it_should_behave_like "a superuser accessing any webconf room"
        end

        context "he is not a member of" do
          it_should_behave_like "a superuser accessing any webconf room"
        end
      end

      context "in the room of private space" do
        let(:space) { FactoryGirl.create(:space, :public => false) }
        let(:room) { space.bigbluebutton_room }

        context "he is a member of" do
          before { space.add_member!(user) }
          it_should_behave_like "a superuser accessing any webconf room"
        end

        context "he is not a member of" do
          it_should_behave_like "a superuser accessing any webconf room"
        end
      end
    end

    context "a normal user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:hash_with_server) { { :server_id => room.server.id } }
      let(:hash) { hash_with_server.merge!(:id => room.to_param) }
      before(:each) { login_as(user) }

      it { should deny_access_to(:index) }
      it { should deny_access_to(:new) }
      it { should deny_access_to(:create).via(:post) }

      context "in his room" do
        let(:room) { user.bigbluebutton_room }
        it { should deny_access_to(:show, hash) }
        it { should deny_access_to(:edit, hash) }
        it { should deny_access_to(:update, hash).via(:put) }
        it { should deny_access_to(:destroy, hash).via(:delete) }
        it { should_not deny_access_to(:join, hash) }
        it { should_not deny_access_to(:auth, hash).via(:post) }
        it { should_not deny_access_to(:invite, hash) }
        it { should_not deny_access_to(:external, hash_with_server) }
        it { should_not deny_access_to(:external_auth, hash_with_server).via(:post) }
        it { should_not deny_access_to(:end, hash) }
        it { should_not deny_access_to(:join_mobile, hash) }
        it { should_not deny_access_to(:running, hash) }
      end

      context "in another user's room" do
        let(:room) { FactoryGirl.create(:superuser).bigbluebutton_room }
        it { should deny_access_to(:show, hash) }
        it { should deny_access_to(:edit, hash) }
        it { should deny_access_to(:update, hash).via(:put) }
        it { should deny_access_to(:destroy, hash).via(:delete) }
        it { should_not deny_access_to(:external, hash_with_server) }
        it { should_not deny_access_to(:external_auth, hash_with_server).via(:post) }
        it { should_not deny_access_to(:join, hash) }
        it { should_not deny_access_to(:auth, hash).via(:post) }
        it { should_not deny_access_to(:invite, hash) }
        it { should deny_access_to(:end, hash) }
        it { should_not deny_access_to(:join_mobile, hash) }
        it { should_not deny_access_to(:running, hash) }
      end

      context "in the room of public space" do
        let(:space) { FactoryGirl.create(:space, :public => true) }
        let(:room) { space.bigbluebutton_room }

        context "he is a member of" do
          before { space.add_member!(user) }
          it { should deny_access_to(:show, hash) }
          it { should deny_access_to(:edit, hash) }
          it { should deny_access_to(:update, hash).via(:put) }
          it { should deny_access_to(:destroy, hash).via(:delete) }
          it { should_not deny_access_to(:external, hash_with_server) }
          it { should_not deny_access_to(:external_auth, hash_with_server).via(:post) }
          it { should_not deny_access_to(:join, hash) }
          it { should_not deny_access_to(:auth, hash).via(:post) }
          it { should_not deny_access_to(:invite, hash) }
          it { should_not deny_access_to(:end, hash) }
          it { should_not deny_access_to(:join_mobile, hash) }
          it { should_not deny_access_to(:running, hash) }
        end

        context "he is not a member of" do
          it { should deny_access_to(:show, hash) }
          it { should deny_access_to(:edit, hash) }
          it { should deny_access_to(:update, hash).via(:put) }
          it { should deny_access_to(:destroy, hash).via(:delete) }
          it { should_not deny_access_to(:external, hash_with_server) }
          it { should_not deny_access_to(:external_auth, hash_with_server).via(:post) }
          it { should_not deny_access_to(:join, hash) }
          it { should_not deny_access_to(:auth, hash).via(:post) }
          it { should_not deny_access_to(:invite, hash) }
          it { should deny_access_to(:end, hash) }
          it { should_not deny_access_to(:join_mobile, hash) }
          it { should_not deny_access_to(:running, hash) }
        end
      end

      context "in the room of private space" do
        let(:space) { FactoryGirl.create(:space, :public => false) }
        let(:room) { space.bigbluebutton_room }

        context "he is a member of" do
          before { space.add_member!(user) }
          it { should deny_access_to(:show, hash) }
          it { should deny_access_to(:edit, hash) }
          it { should deny_access_to(:update, hash).via(:put) }
          it { should deny_access_to(:destroy, hash).via(:delete) }
          it { should_not deny_access_to(:external, hash_with_server) }
          it { should_not deny_access_to(:external_auth, hash_with_server).via(:post) }
          it { should_not deny_access_to(:join, hash) }
          it { should_not deny_access_to(:auth, hash).via(:post) }
          it { should_not deny_access_to(:invite, hash) }
          it { should_not deny_access_to(:end, hash) }
          it { should_not deny_access_to(:join_mobile, hash) }
          it { should_not deny_access_to(:running, hash) }
        end

        context "he is not a member of" do
          it { should deny_access_to(:show, hash) }
          it { should deny_access_to(:edit, hash) }
          it { should deny_access_to(:update, hash).via(:put) }
          it { should deny_access_to(:destroy, hash).via(:delete) }
          it { should_not deny_access_to(:external, hash_with_server) }
          it { should_not deny_access_to(:external_auth, hash_with_server).via(:post) }
          it { should_not deny_access_to(:join, hash) }
          it { should_not deny_access_to(:auth, hash).via(:post) }
          it { should_not deny_access_to(:invite, hash) }
          it { should deny_access_to(:end, hash) }
          it { should_not deny_access_to(:join_mobile, hash) }
          it { should_not deny_access_to(:running, hash) }
        end
      end

    end

    context "an anonymous user" do
      let(:hash_with_server) { { :server_id => room.server.id } }
      let(:hash) { hash_with_server.merge!(:id => room.to_param) }

      it { should deny_access_to(:index).using_code(:redirect) }
      it { should deny_access_to(:new).using_code(:redirect) }
      it { should deny_access_to(:create).via(:post).using_code(:redirect) }

      # the permissions are always the same, doesn't matter the type of room, so
      # we have them all in this common method
      shared_examples_for "an anonymous user accessing any webconf room" do
        it { should deny_access_to(:show, hash).using_code(:redirect) }
        it { should deny_access_to(:edit, hash).using_code(:redirect) }
        it { should deny_access_to(:update, hash).via(:put).using_code(:redirect) }
        it { should deny_access_to(:destroy, hash).via(:delete).using_code(:redirect) }
        it { should deny_access_to(:join, hash).using_code(:redirect) }
        it { should_not deny_access_to(:auth, hash).via(:post).using_code(:redirect) }
        it { should_not deny_access_to(:invite, hash) }
        it { should deny_access_to(:external, hash_with_server).using_code(:redirect) }
        it { should deny_access_to(:external_auth, hash_with_server).via(:post).using_code(:redirect) }
        it { should deny_access_to(:end, hash).using_code(:redirect) }
        it { should deny_access_to(:join_mobile, hash).using_code(:redirect) }
        it { should_not deny_access_to(:running, hash) }
      end

      context "in a user room" do
        let(:room) { FactoryGirl.create(:superuser).bigbluebutton_room }
        it_should_behave_like "an anonymous user accessing any webconf room"
      end

      context "in the room of public space" do
        let(:space) { FactoryGirl.create(:space, :public => true) }
        let(:room) { space.bigbluebutton_room }
        it_should_behave_like "an anonymous user accessing any webconf room"
      end

      context "in the room of private space" do
        let(:space) { FactoryGirl.create(:space, :public => false) }
        let(:room) { space.bigbluebutton_room }
        it_should_behave_like "an anonymous user accessing any webconf room"
      end
    end
  end

  pending "uses the layout 'application' except for #join_mobile"
  pending "#join_mobile uses no layout"
end
