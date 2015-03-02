# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe ProfilesController do
  include Shoulda::Matchers::ActionController

  describe "routing" do
    it { should route(:get, '/users/u1/profile/edit').to(action: :edit, user_id: 'u1') }
    it { should route(:get, '/users/u1/profile.vcf').to(action: :show, user_id: 'u1', format: :vcf) }
    # make sure some routes don't exist
    it { { :get => '/users/u1/profile/new' }.should_not be_routable }
    it { { :post => '/users/u1/profile' }.should_not be_routable }
    it { { :get => '/spaces/s1/users/u1/profile/new' }.should_not be_routable }
    it { { :post => '/spaces/s1/users/u1/profile' }.should_not be_routable }
  end
end
