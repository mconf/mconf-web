# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe SitesController do
  include Shoulda::Matchers::ActionController

  describe "routing" do
    it { should route(:get, "/site").to(:action => :show) }
    it { should route(:get, "/site/edit").to(:action => :edit) }
    it { should route(:put, "/site").to(:action => :update) }
    it { should_not route(:get, "/sites").to(:action => :index) }
    it { should_not route(:delete, "/site/s1").to(:action => :destroy, :id => "s1") }
    it { should_not route(:get, "/site/new").to(:action => :new) }
    it { should_not route(:post, "/site").to(:action => :create) }
  end
end
