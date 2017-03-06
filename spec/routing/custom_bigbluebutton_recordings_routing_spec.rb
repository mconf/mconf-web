# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe CustomBigbluebuttonRecordingsController do
  include Shoulda::Matchers::ActionController

  describe "routing" do
    # test a few routes from the gem just to make sure the scope is right
    it { should route(:get, "/#{Rails.application.config.conf_scope}/recordings").to(action: :index) }
    it { should route(:get, "/#{Rails.application.config.conf_scope}/recordings/my-recording").to(action: :show, id: "my-recording") }
    it { should route(:get, "/#{Rails.application.config.conf_scope}/recordings/my-recording/edit").to(action: :edit, id: "my-recording") }
  end
end
