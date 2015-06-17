# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe ProfilesController do
  render_views

  describe "#show" do
    let(:user) { FactoryGirl.create(:user) }
    before { sign_in user }

    context ".html" do
      before {
        get :show, user_id: user.to_param
      }
      it { should redirect_to user_path(user) }
    end

    context ".vcf" do
      before {
        get :show, format: :vcf, id: user.profile.to_param
      }
      it "downloads the user profile in a .vcf file"
      it "uses the correct filename"
    end
  end

end
