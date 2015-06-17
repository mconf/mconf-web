# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'
require 'support/feature_helpers'

feature 'Behaviour of the flag Site#local_auth_enabled' do
  let(:user) { FactoryGirl.create(:user) }
  let(:admin) { FactoryGirl.create(:superuser) }

  context "when the flag is set" do
    before { Site.current.update_attributes(local_auth_enabled: true) }

    scenario 'allows local authentication for normal users' do
      sign_in_with user.username, user.password
      expect(current_path).to eq(my_home_path)
    end

    scenario "shows the 'recover password' link in the login page"
    scenario "shows the 'sign in' link in the login page"
    scenario "shows the 'login' link in the navbar even if LDAP is disabled"
    scenario "shows the password inputs in users/edit even for normal users"

  end

  context "when the flag is not set" do
    before { Site.current.update_attributes(local_auth_enabled: false) }

    scenario 'blocks sign in for normal users' do
      sign_in_with user.username, user.password
      expect(current_path).to eq(new_user_session_path)
    end

    scenario 'allows the sign in of admins' do
      sign_in_with admin.username, admin.password
      expect(current_path).to eq(my_home_path)
    end

    scenario "still shows the 'recover password' link in the login page"
    scenario "still shows the 'sign in' link in the login page"
    scenario "hides the 'login' link from the navbar if LDAP is also disabled"
    scenario "hides the password inputs from users/edit"
    scenario "shows the password inputs in users/edit if the user is an admin"

  end
end
