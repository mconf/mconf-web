# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe UsersController do
  include Shoulda::Matchers::ActionController

  describe "routing" do
    it { should route(:get, "/users").to(:action => :index) }
    it { should route(:get, "/users/fellows").to(:action => :fellows) }
    it { should route(:get, "/users/current").to(:action => :current) }
    it { should route(:get, "/users/select").to(:action => :select) }
    it { should route(:get, "/users/u1").to(:action => :show, :id => "u1") }
    it { should route(:get, "/users/u1/edit").to(:action => :edit, :id => "u1") }
    it { should route(:put, "/users/u1").to(:action => :update, :id => "u1") }
    it { should route(:delete, "/users/u1").to(:action => :destroy, :id => "u1") }
    it { should route(:post, "/users/u1/enable").to(:action => :enable, :id => "u1") }
    it { should_not route(:get, "/users/new").to(:action => :new) }
    it { should_not route(:post, "/users").to(:action => :create) }
    it { should route(:post, "/users/u1/approve").to(:action => :approve, :id => "u1") }
    it { should route(:post, "/users/u1/disapprove").to(:action => :disapprove, :id => "u1") }
  end
end
