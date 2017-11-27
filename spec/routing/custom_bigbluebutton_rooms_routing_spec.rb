# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe CustomBigbluebuttonRoomsController do
  include Shoulda::Matchers::ActionController

  describe "routing" do

    # test a few routes from the gem just to make sure the scope is right
    it { should route(:get, "/#{Rails.application.config.conf_scope}/rooms").to(action: :index) }
    it { should route(:get, "/#{Rails.application.config.conf_scope}/rooms/my-room").to(action: :show, id: "my-room") }
    it { should route(:get, "/#{Rails.application.config.conf_scope}/rooms/my-room/edit").to(action: :edit, id: "my-room") }

    it { should route(:get, "/#{Rails.application.config.conf_scope}/rooms/my-room/invitation").to(action: :invitation, id: "my-room") }
    it { should route(:post, "/#{Rails.application.config.conf_scope}/rooms/my-room/send_invitation").to(action: :send_invitation, id: "my-room") }
    it { should route(:get, "/#{Rails.application.config.conf_scope}/rooms/my-room/user_edit").to(action: :user_edit, id: "my-room") }

    context "with a scope for rooms" do
      set_conf_scope_rooms('webconf')
      it { should route(:get, "/webconf/my-room").to(action: :invite_userid, id: "my-room") }
    end

    context "with an empty scope for rooms" do
      set_conf_scope_rooms('')
      it { should route(:get, "/my-room").to(action: :invite_userid, id: "my-room") }
    end

  end
end
