# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe SpacesController do
  include Shoulda::Matchers::ActionController

  # TODO: not all routes are being tested
  describe "routing" do
    it { should route(:get, "/spaces").to(:action => :index) }
    it { should route(:get, "/spaces/new").to(:action => :new) }
    it { should route(:post, "/spaces").to(:action => :create) }
    it { should route(:get, "/spaces/s1").to(:action => :show, :id => "s1") }
    it { should route(:get, "/spaces/s1/edit").to(:action => :edit, :id => "s1") }
    it { should route(:put, "/spaces/s1").to(:action => :update, :id => "s1") }
    it { should route(:delete, "/spaces/s1").to(:action => :destroy, :id => "s1") }
  end
end
