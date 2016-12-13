# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe CustomBigbluebuttonServersController do
  render_views

  describe "#sort_meetings" do
    skip "sort meetings alphabetically by name"
  end

  describe "#activity" do
    skip "calls before filter #sort_meetings"
  end

  describe "#check" do
    skip "doesn't require authentication"
    skip "doesn't authorize resources"
  end

  describe "abilities", :abilities => true do
    render_views(false)
    let(:server) { FactoryGirl.create(:bigbluebutton_server) }

    context "for a superuser", :user => "superuser" do
      let(:user) { FactoryGirl.create(:superuser) }
      let(:hash) { { :id => server.to_param } }
      before(:each) { login_as(user) }

      it { should allow_access_to(:index) }
      it { should allow_access_to(:new) }
      it { should allow_access_to(:create).via(:post) }
      it { should allow_access_to(:show, hash) }
      it { should allow_access_to(:edit, hash) }
      it { should allow_access_to(:update, hash).via(:put) }
      it { should allow_access_to(:destroy, hash).via(:delete) }
      it { should allow_access_to(:activity, hash) }
      it { should allow_access_to(:recordings, hash) }
      it { should allow_access_to(:rooms, hash) }
      it { should allow_access_to(:publish_recordings, hash).via(:post) }
      it { should allow_access_to(:unpublish_recordings, hash).via(:post) }
      it { should allow_access_to(:fetch_recordings, hash).via(:post) }
    end

    context "for a normal user", :user => "normal" do
      let(:user) { FactoryGirl.create(:user) }
      let(:hash) { { :id => server.to_param } }
      before(:each) { login_as(user) }

      it { should_not allow_access_to(:index) }
      it { should_not allow_access_to(:new) }
      it { should_not allow_access_to(:create).via(:post) }
      it { should_not allow_access_to(:show, hash) }
      it { should_not allow_access_to(:edit, hash) }
      it { should_not allow_access_to(:update, hash).via(:put) }
      it { should_not allow_access_to(:destroy, hash).via(:delete) }
      it { should_not allow_access_to(:activity, hash) }
      it { should_not allow_access_to(:recordings, hash) }
      it { should_not allow_access_to(:rooms, hash) }
      it { should_not allow_access_to(:publish_recordings, hash).via(:post) }
      it { should_not allow_access_to(:unpublish_recordings, hash).via(:post) }
      it { should_not allow_access_to(:fetch_recordings, hash).via(:post) }
    end

    context "for an anonymous user", :user => "anonymous" do
      let(:hash) { { :id => server.to_param } }

      it { should require_authentication_for(:index) }
      it { should require_authentication_for(:new) }
      it { should require_authentication_for(:create).via(:post) }
      it { should require_authentication_for(:show, hash) }
      it { should require_authentication_for(:edit, hash) }
      it { should require_authentication_for(:update, hash).via(:put) }
      it { should require_authentication_for(:destroy, hash).via(:delete) }
      it { should require_authentication_for(:activity, hash) }
      it { should require_authentication_for(:recordings, hash) }
      it { should require_authentication_for(:rooms, hash) }
      it { should require_authentication_for(:publish_recordings, hash).via(:post) }
      it { should require_authentication_for(:unpublish_recordings, hash).via(:post) }
      it { should require_authentication_for(:fetch_recordings, hash).via(:post) }
    end
  end

end
