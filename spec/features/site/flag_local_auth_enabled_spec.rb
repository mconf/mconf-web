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

    context 'allows facebook authentication for normal users' do
      before {
        Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:facebook]
        visit login_path
      }

      it {
        page.find(:css, ".btn-facebook").click
        expect(current_path).to eq(my_home_path)
      }
    end

    context 'allows google authentication for normal users' do
      before {
        Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:google_oauth2]
        visit login_path
      }

      it {
        page.find(:css, ".btn-google").click
        expect(current_path).to eq(my_home_path)
      }
    end

    context "shows the 'recover password' link in the login page" do
      before { visit new_user_session_path }

      it { page.should have_content(t('sessions.login_form.lost_password')) }
      it { page.should have_css("input[type='submit'][value='#{t('sessions.login_form.login')}']") }
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

    scenario 'accessing the standard login route' do
      visit new_user_session_path
      expect(current_path).to eq(root_path)
    end

    context 'allows facebook authentication for normal users' do
      before {
        Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:facebook]
        visit register_path
      }

      it {
        page.find(:css, ".btn-facebook").click
        expect(current_path).to eq(my_home_path)
      }
    end

    context 'allows google authentication for normal users' do
      before {
        Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:google_oauth2]
        visit register_path
      }

      it {
        page.find(:css, ".btn-google").click
        expect(current_path).to eq(my_home_path)
      }
    end

    context "accessing from the admin sign in page" do
      scenario 'blocks sign in for normal users' do
        visit admin_login_path
        sign_in_with user.username, user.password, false
        expect(current_path).to eq(root_path)
      end

      scenario 'allows the sign in of admins' do
        visit admin_login_path
        sign_in_with admin.username, admin.password, false
        expect(current_path).to eq(my_home_path)
      end

      context "still shows login links in login page for admin" do
        before { visit admin_login_path }

        it { page.should have_content(t('sessions.login_form.lost_password')) }
        it { page.should have_css("input[type='submit'][value='#{t('sessions.login_form.login')}']") }

        it "hide 'login' link from navbar if ldap is not enabled" do
          page.should_not have_css("#navbar a[href='#{login_path}']")
        end
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
