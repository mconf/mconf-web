# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe MyController do
  include Shoulda::Matchers::ActionController

  describe "routing" do
    it { should route(:get, "/my/home").to(:action => :home) }
    it { should route(:get, "/my/rooms.json").to(:action => :rooms, :format => :json) }
    it { should_not route(:get, "/my/rooms.html").to(:action => :rooms) }
    it { should route(:get, "/my/activity").to(:action => :activity) }
    it { should route(:get, "/my/webconference/edit").to(:action => :webconference_edit) }
    it { should route(:get, "/my/webconference/recordings").to(:action => :webconference_recordings) }
  end
end
