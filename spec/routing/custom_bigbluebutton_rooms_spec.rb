# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe CustomBigbluebuttonRoomsController do
  include Shoulda::Matchers::ActionController

  describe "routing" do
    it { should route(:get, "/bigbluebutton/rooms/1/join_options").to(:action => :join_options, :id => "1") }
  end
end
