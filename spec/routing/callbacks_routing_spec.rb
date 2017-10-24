# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2017 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe CallbacksController do
  include Shoulda::Matchers::ActionController

  describe "routing" do
    it { should route(:get, "/users/auth/google_oauth2").to(:action => :passthru, :provider => "google_oauth2") }
    it { should route(:get, "/users/auth/facebook").to(:action => :passthru, :provider => "facebook") }
    it { should route(:get, "/users/auth/google_oauth2/callback").to(:action => "google_oauth2") }
    it { should route(:get, "/users/auth/facebook/callback").to(:action => "facebook") }
  end
end
