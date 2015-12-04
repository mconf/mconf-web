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

    context "shows the 'recover password' link in the login page" do
      before { visit new_user_session_path }

      it { page.should have_content(t('devise.shared.links.lost_password')) }
      it { page.should have_css("input[type='submit'][value='Login']") }
      it { page.should have_css("#navbar a[href='#{login_path}']") }
    end

    context "shows the 'login' link in the navbar even if LDAP is disabled" do
      before {
        Site.current.update_attributes(ldap_enabled: false)
        visit new_user_session_path
      }

      it { page.should have_css("#navbar a[href='#{login_path}']") }
    end

    context "shows the password inputs in users/edit even for normal users" do
      before {
        login_as(user) # sign in with devise to simulate user logged in via shib/ldap
        visit edit_user_path(user)
      }

      it { page.should have_css('input#user_password') }
      it { page.should have_css('input#user_password_confirmation') }
    end

    context "shows the password inputs in users/edit if the user is an admin" do
      before {
        login_as(admin)
        visit edit_user_path(admin)
      }

      it { page.should have_css('input#user_password') }
      it { page.should have_css('input#user_password_confirmation') }
    end
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

    context "still shows login links in login page for admin" do
      before { visit new_user_session_path }

      it { page.should have_content(t('devise.shared.links.lost_password')) }
      it { page.should have_css("input[type='submit'][value='Login']") }

      it "hide 'login' link from navbar if ldap is not enabled" do
        page.should_not have_css("#navbar a[href='#{login_path}']")
      end
    end

    context "hides the password inputs from users/edit" do
      before {
        login_as(user) # sign in with devise to simulate user logged in via shib/ldap
        visit edit_user_path(user)
      }

      it { page.should_not have_css('input#user_password') }
      it { page.should_not have_css('input#user_password_confirmation') }
    end

    context "shows the password inputs in users/edit if the user is an admin and edits himself" do
      before { login_as(admin) }

      context 'edits himself' do
        before { visit edit_user_path(admin) }
        it { page.should have_css('input#user_password') }
        it { page.should have_css('input#user_password_confirmation') }
      end

      context 'edits a normal user' do
        before { visit edit_user_path(user) }
        it { page.should_not have_css('input#user_password') }
        it { page.should_not have_css('input#user_password_confirmation') }
      end
    end

    context "shows 'login' link from the navbar if LDAP is also enabled" do
      before {
        Site.current.update_attributes(local_auth_enabled: false, ldap_enabled: true)
        visit new_user_session_path
      }

      it { page.should have_css("#navbar a[href='#{login_path}']") }
    end

  end
end
