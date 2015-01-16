# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe CustomBigbluebuttonPlaybackTypesController do
  render_views

  describe "#index" do
    before(:each) {
      login_as(FactoryGirl.create(:superuser))
      get :index
    }

    context "template and layout" do
      it { should render_template(:index) }
      it { should render_with_layout("application") }
    end

    context "loads the playback types into @playback_types" do
      before {
        5.times {
          FactoryGirl.create(:bigbluebutton_playback_format).playback_type
        }
      }
      it { should assign_to(:playback_types).with(BigbluebuttonPlaybackType.all) }
    end
  end

  describe "abilities", :abilities => true do
    render_views(false)
    let!(:playback_type) { FactoryGirl.create(:bigbluebutton_playback_format).playback_type }
    let(:hash) { { :id => playback_type.to_param } }

    context "for a superuser", :user => "superuser" do
      let(:user) { FactoryGirl.create(:superuser) }
      before(:each) { login_as(user) }

      it { should allow_access_to(:index) }
      it { should allow_access_to(:update, hash).via(:put) }
    end

    context "for a normal user", :user => "normal" do
      let(:user) { FactoryGirl.create(:user) }
      before(:each) { login_as(user) }

      it { should_not allow_access_to(:index) }
      it { should_not allow_access_to(:update, hash).via(:put) }
    end

    context "for an anonymous user", :user => "anonymous" do
      it { should require_authentication_for(:index) }
      it { should require_authentication_for(:update, hash).via(:put) }
    end
  end

end
