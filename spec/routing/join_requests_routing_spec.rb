# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe JoinRequestsController do
  include Shoulda::Matchers::ActionController

  describe "routing" do
    it { should route(:get, "/spaces/s1/join_requests").to(action: :index, space_id: "s1") }
    it { should route(:get, "/spaces/s1/join_requests/2").to(action: :show, space_id: "s1", id: 2) }
    it { should route(:get, "/spaces/s1/join_requests/new").to(action: :new, space_id: "s1") }
    it { should route(:post, "/spaces/s1/join_requests").to(action: :create, space_id: "s1") }
    it { should route(:get, "/spaces/s1/join_requests/invite").to(action: :invite, space_id: "s1") }
    it { should route(:post, "/spaces/s1/join_requests/2/accept").to(action: :accept, space_id: "s1", id: 2) }
    it { should route(:post, "/spaces/s1/join_requests/2/decline").to(action: :decline, space_id: "s1", id: 2) }
  end
end
