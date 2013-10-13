# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe ShibbolethController do
  include Shoulda::Matchers::ActionController

  describe "routing" do
    it { should route(:get, "/secure").to(:action => :login) }
    it { should route(:get, "/secure/info").to(:action => :info) }
  end
end
