# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe ShibbolethController do
  include Shoulda::Matchers::ActionController

  describe "routing" do
    it { should route(:get, "/users/shibboleth").to(:action => :login) }
    it { should route(:get, "/users/shibboleth/info").to(:action => :info) }
    it { should route(:post, "/users/shibboleth/associate").to(:action => :create_association) }
  end
end
