# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe MyController do
  render_views

  it "#show"
  it "#activity"
  it "#rooms"

  describe "#webconference_edit" do
    let(:user) { FactoryGirl.create(:user) }
    before(:each) { login_as(user) }

    context "html request" do
      before(:each) { get :webconference_edit }
      it { should render_template(:webconference_edit) }
      it { should render_with_layout("application") }
      it { should assign_to(:room).with(user.bigbluebutton_room) }
      it { should assign_to(:redirect_to).with(my_home_path) }
    end

    context "xhr request" do
      before(:each) { xhr :get, :webconference_edit }
      it { should render_template(:webconference_edit) }
      it { should_not render_with_layout }
    end
  end

end
