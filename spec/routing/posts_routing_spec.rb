# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe PostsController do
  include Shoulda::Matchers::ActionController

  # TODO: not all routes are being tested
  describe "routing" do
    it { should route(:get, "/spaces/s1/posts").to(:action => :index, :space_id => "s1") }
    it { should route(:get, "/spaces/s1/posts/new").to(:action => :new, :space_id => "s1") }
    it { should route(:post, "/spaces/s1/posts").to(:action => :create, :space_id => "s1") }
    it { should route(:get, "/spaces/s1/posts/p1").to(:action => :show, :space_id => "s1", :id => "p1") }
    it { should route(:get, "/spaces/s1/posts/p1/edit").to(:action => :edit, :space_id => "s1", :id => "p1") }
    it { should route(:put, "/spaces/s1/posts/p1").to(:action => :update, :space_id => "s1", :id => "p1") }
    it { should route(:delete, "/spaces/s1/posts/p1").to(:action => :destroy, :space_id => "s1", :id => "p1") }
  end
end
