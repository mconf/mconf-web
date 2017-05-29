# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe MyController do
  include Shoulda::Matchers::ActionController

  describe "routing" do
    it { should route(:get, "/home").to(:action => :home) }
    it { should route(:get, "/home/activity").to(:action => :activity) }
    it { should route(:get, "/home/meetings").to(:action => :meetings) }
  end
end
