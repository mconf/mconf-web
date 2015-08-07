# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe 'User signs in via ldap' do
  subject { page }
  before(:all) {
    @attrs = FactoryGirl.attributes_for(:user, :email => "user@mconf.org")
  }

  context 'for the first time' do
    before {
      enable_ldap
      visit new_user_session_path
    }

    context 'and the user is registered in the ldap server' do
      before { click_button t('sessions.login_form.login') }

      it { current_path.should eq(my_home_path) }
      it { should have_content @attrs[:_full_name] }
      it { should have_content @attrs[:email] }
    end

    context 'and the user is already registered for the site' do

      context 'and enters valid credentials' do
        let(:user) { FactoryGirl.create(:user) }
        before {
          fill_in 'user[login]', :with => user.username
          fill_in 'user[password]', :with => user.password
          click_button t('sessions.login_form.login')
        }

        it { current_path.should eq(my_home_path) }
        it { should have_content user._full_name }
        it { should have_content user.email }
      end

      context "the user enters the wrong credentials in the association page" do
        before { click_button t('sessions.login_form.login') }

        it { has_failure_message }
        it { current_path.should eq(new_user_session_path) }
      end

      context "the user's account is disabled" do
        let(:user) { FactoryGirl.create(:user) }
        before {
          user.disable
          fill_in 'user[login]', :with => user.username
          fill_in 'user[password]', :with => user.password
          click_button t('sessions.login_form.login')
        }

        it { has_failure_message }
        it { current_path.should eq(new_user_session_path) }
      end
    end

    context "creating the user's account" do
      context "successfully" do
        before {
          expect {
            click_button t('sessions.login_form.login')
          }.to change{ User.count }
        }

        it { current_path.should eq(my_home_path) }
        it("creates a LdapToken") { LdapToken.count.should be(1) }
        it("sends notification emails") { UserMailer.should have_queue_size_of(1) }
        it("sends notification emails") { UserMailer.should have_queued(:registration_notification_email, User.last.id) }
      end

      context "but encountering a server error" do

      end

      context "and there's a conflict on the user's username with another user" do
        before {
          FactoryGirl.create(:user, username: @attrs[:_full_name].parameterize)
          expect {
            click_button t('sessions.login_form.login')
          }.not_to change{ User.count }
        }

        it { current_path.should eq(new_user_session_path) }
        it { has_failure_message "Username has already been taken" }
        it("doesn't create a LdapToken") { LdapToken.count.should be(0) }
        it("doesn't send emails") { UserMailer.should have_queue_size_of(0) }
      end

      context "and there's a conflict on the user's username with a space" do
        before {
          FactoryGirl.create(:space, permalink: @attrs[:_full_name].parameterize)
          expect {
            click_button t('sessions.login_form.login')
          }.not_to change{ User.count }
        }

        it { current_path.should eq(new_user_session_path) }
        it { has_failure_message "Username has already been taken" }
        it("doesn't create a LdapToken") { LdapToken.count.should be(0) }
        it("doesn't send emails") { UserMailer.should have_queue_size_of(0) }
      end

      context "and there's a conflict on the user's username with a room" do
        before {
          FactoryGirl.create(:bigbluebutton_room, param: @attrs[:_full_name].parameterize)
          expect {
            click_button t('sessions.login_form.login')
          }.not_to change{ User.count }
        }

        it { current_path.should eq(new_user_session_path) }
        it { has_failure_message "Username has already been taken" }
        it("doesn't create a LdapToken") { LdapToken.count.should be(0) }
        it("doesn't send emails") { UserMailer.should have_queue_size_of(0) }
      end

      context "and there's a conflict in the user's email" do
        before {
          FactoryGirl.create(:user, email: @attrs[:email])
          expect {
            click_button t('sessions.login_form.login')
          }.not_to change{ User.count }
        }

        it { current_path.should eq(new_user_session_path) }
        it { has_failure_message t('shibboleth.create_association.existent_account', email: @attrs[:email]) }
        it("doesn't create a LdapToken") { LdapToken.count.should be(0) }
        it("doesn't send emails") { UserMailer.should have_queue_size_of(0) }
      end
    end
  end

  context "a returning user" do
    let(:token) { FactoryGirl.create(:ldap_token) }
    let(:user) { token.user }

    before {
      enable_ldap
      # setup_shib user.full_name, user.email, user.email
    }

    context "that has a valid account" do
      before {
        visit new_user_session_path
      }

      # it { current_path.should eq(my_home_path) }
      # it { should have_content user.full_name }
      # it { should have_content user.email }
    end

    context "that has a disabled account" do
      before {
        user.disable
        visit new_user_session_path
      }

      it { current_path.should eq(root_path) }
      it { has_failure_message(I18n.t('shibboleth.login.local_account_disabled')) }
    end
  end

  context "redirects the user properly" do
    # let!(:login_link) { t('devise.shared.links.login.federation') }
    # before {
    #   enable_shib
    #   Site.current.update_attributes :shib_always_new_account => true
    #   setup_shib 'a full name', 'user@mconf.org', 'user@mconf.org'
    # }

    # context "when he was in the frontpage" do
    #   before {
    #     visit root_url
    #     click_link login_link
    #   }

    #   it { current_path.should eq(my_home_path) }
    # end

    # context "from a space's page" do
    #   before {
    #     @space = FactoryGirl.create(:space, :public => true)
    #     visit space_path(@space)

    #     # Access sign in path via link
    #     find("a[href='#{new_user_session_path}']").click

    #     click_link login_link
    #   }

    #   it { current_path.should eq(space_path(@space)) }
    # end
  end

end
