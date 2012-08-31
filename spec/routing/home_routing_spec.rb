# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe HomesController do
  include Shoulda::Matchers::ActionController

  describe "routing" do
    it { should route(:get, "/home").to(:action => :show) }
    it { should route(:get, "/home/user_rooms.json").to(:action => :user_rooms, :format => :json) }
    it { should_not route(:get, "/home/user_rooms.html").to(:action => :user_rooms) }
  end
end
