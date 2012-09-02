# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe CustomBigbluebuttonServersController do
  include ActionController::AuthenticationTestHelper

  context "checks access permissions for a(n)" do
    render_views false
    let(:server) { FactoryGirl.create(:bigbluebutton_server) }
    let(:hash) { { :id => server.to_param } }

    context "superuser" do
      before(:each) { login_as(FactoryGirl.create(:superuser)) }
      it { should_not deny_access_to(:index) }
      it { should_not deny_access_to(:new) }
      it { should_not deny_access_to(:show, hash) }
      it { should_not deny_access_to(:edit, hash) }
      it { should_not deny_access_to(:activity, hash) }
      it { should_not deny_access_to(:create).via(:post) }
      it { should_not deny_access_to(:update, hash).via(:put) }
      it { should_not deny_access_to(:destroy, hash).via(:delete) }
      it { should_not deny_access_to(:rooms, hash) }
    end

    context "user" do
      before(:each) { login_as(FactoryGirl.create(:user)) }
      it { should deny_access_to(:index) }
      it { should deny_access_to(:new) }
      it { should deny_access_to(:show, hash) }
      it { should deny_access_to(:edit, hash) }
      it { should deny_access_to(:activity, hash) }
      it { should deny_access_to(:create).via(:post) }
      it { should deny_access_to(:update, hash).via(:put) }
      it { should deny_access_to(:destroy, hash).via(:delete) }
      it { should deny_access_to(:rooms, hash) }
    end

    context "anonymous user" do
      it { should deny_access_to(:index).using_code(:redirect) }
      it { should deny_access_to(:new).using_code(:redirect) }
      it { should deny_access_to(:show, hash).using_code(:redirect) }
      it { should deny_access_to(:edit, hash).using_code(:redirect) }
      it { should deny_access_to(:activity, hash).using_code(:redirect) }
      it { should deny_access_to(:create).via(:post).using_code(:redirect) }
      it { should deny_access_to(:update, hash).via(:put).using_code(:redirect) }
      it { should deny_access_to(:destroy, hash).via(:delete).using_code(:redirect) }
      it { should deny_access_to(:rooms, hash).using_code(:redirect) }
    end

  end

end
