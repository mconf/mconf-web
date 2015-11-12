# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'
require 'support/feature_helpers'

include ActionView::Helpers::SanitizeHelper

feature 'LDAP is misconfigured', ldap: true do
  subject { page }
  before(:all) {
    Mconf::LdapServerRunner.add_default_user
    Mconf::LdapServerRunner.start
  }
  after(:all) { Mconf::LdapServerRunner.stop }

  before { enable_ldap }

  scenario "doesn't break the local sign in with wrong port" do
    port = Mconf::LdapServer.default_ldap_configs[:ldap_port]
    Site.current.update_attributes ldap_port: port + 1

    user = FactoryGirl.create(:user, username: 'user', password: 'password')
    sign_in_with user.email, user.password

    expect(page).to have_title(I18n.t('home.my'))
    expect(page).to have_content(I18n.t('home.my_spaces'))
    expect(current_path).to eq(my_home_path)
  end

  scenario "doesn't break the local sign in with unreacheable server" do
    Site.current.update_attributes ldap_host: "nonexistanturl.doesntexist"

    user = FactoryGirl.create(:user, username: 'user', password: 'password')
    sign_in_with user.email, user.password

    expect(page).to have_title(I18n.t('home.my'))
    expect(page).to have_content(I18n.t('home.my_spaces'))
    expect(current_path).to eq(my_home_path)
  end

end
