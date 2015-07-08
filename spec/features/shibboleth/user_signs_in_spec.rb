# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'
require 'support/feature_helpers'

include ActionView::Helpers::SanitizeHelper

describe 'User signs in via shibboleth' do
  subject { page }
  before(:all) {
    @attrs = FactoryGirl.attributes_for(:user, :email => "user@mconf.org")
  }

  context "for the first time when the flag `shib_always_new_account` is set" do
    before {
      enable_shib
      Site.current.update_attributes :shib_always_new_account => true

      setup_shib @attrs[:_full_name], @attrs[:email], @attrs[:email]

      visit shibboleth_path
    }

    it { current_path.should eq(my_home_path) }
    it { should have_content @attrs[:_full_name] }
    it { should have_content @attrs[:email] }
    it { has_success_message strip_links(t('shibboleth.create_association.account_created', :url => new_user_password_path))}
    it { should_not have_content t('my.home.not_confirmed') }
    context "should generate a RecentActivity" do
      subject { RecentActivity.where(key: 'shibboleth.user.created').last }
      it { puts subject.inspect }
      it { subject.should_not be_nil }
      it { subject.trackable.should eq User.last }
      it { subject.owner.should eq ShibToken.last }
    end
  end

  context "for the first time when the flag `shib_always_new_account` is not set" do
    before {
      enable_shib
      setup_shib @attrs[:_full_name], @attrs[:email], @attrs[:email]
      visit shibboleth_path
    }

    it { current_path.should eq(shibboleth_path) }

    it { should have_content t('shibboleth.associate.existent_account.title') }
    it { should have_button t('shibboleth.associate.existent_account.link_to_this_account') }

    it { should have_content t('shibboleth.associate.new_account.title') }
    it { should have_button t('shibboleth.associate.new_account.create_new_account') }
  end

  context 'for the first time' do
    before {
      enable_shib
      setup_shib @attrs[:_full_name], @attrs[:email], @attrs[:email]
      visit shibboleth_path
    }

    context 'and the user wants a new account' do
      before { click_button t('shibboleth.associate.new_account.create_new_account') }

      it { current_path.should eq(my_home_path) }
      it { should have_content @attrs[:_full_name] }
      it { should have_content @attrs[:email] }
    end

    context 'and the user already has another account' do
      context 'and enters valid credentials' do
        let(:user) { FactoryGirl.create(:user) }
        before {
          fill_in 'user[login]', :with => user.username
          fill_in 'user[password]', :with => user.password
          click_button t('shibboleth.associate.existent_account.link_to_this_account')
        }

        it { current_path.should eq(my_home_path) }
        it { should have_content user._full_name }
        it { should have_content user.email }
        it { has_success_message t('shibboleth.create_association.account_associated', :email => user.email)}
        it { should_not have_content t('my.home.not_confirmed') }
        it { UserMailer.should have_queue_size_of(0) }
      end

      context "the user enters the wrong credentials in the association page" do
        before { click_button t('shibboleth.associate.existent_account.link_to_this_account') }

        it { has_failure_message }
        it { current_path.should eq(shibboleth_path) }
      end

      context "the user's account is not confirmed and gets confirmed" do
        let(:user) { FactoryGirl.create(:user) }
        before {
          user.update_attributes :confirmed_at => nil
          fill_in 'user[login]', :with => user.username
          fill_in 'user[password]', :with => user.password
          click_button t('shibboleth.associate.existent_account.link_to_this_account')
        }

        it { has_success_message }
        it { current_path.should eq(my_home_path) }
        it { has_success_message t('shibboleth.create_association.account_associated', :email => user.email)}
        it { should_not have_content t('my.home.not_confirmed') }
        it { UserMailer.should have_queue_size_of(0) }
      end

      context "the user's account is disabled" do
        let(:user) { FactoryGirl.create(:user) }
        before {
          user.disable
          fill_in 'user[login]', :with => user.username
          fill_in 'user[password]', :with => user.password
          click_button t('shibboleth.associate.existent_account.link_to_this_account')
        }

        it { has_failure_message }
        it { current_path.should eq(shibboleth_path) }
      end
    end

    context "creating the user's account" do
      context "successfully" do
        before {
          expect {
            click_button t('shibboleth.associate.new_account.create_new_account')
          }.to change{ User.count }
        }

        it { current_path.should eq(my_home_path) }
        it("creates a ShibToken") { ShibToken.count.should be(1) }
        it("generates a RecentActivity") { RecentActivity.last.trackable.should eql(User.last) }
      end

      context "and there's a conflict on the user's username with another user" do
        before {
          FactoryGirl.create(:user, username: @attrs[:_full_name].parameterize)
          expect {
            click_button t('shibboleth.associate.new_account.create_new_account')
          }.not_to change{ User.count }
        }

        it { current_path.should eq(shibboleth_path) }
        it { has_failure_message "Username has already been taken" }
        it("doesn't create a ShibToken") { ShibToken.count.should be(0) }
        it("doesn't send emails") { UserMailer.should have_queue_size_of(0) }
      end

      context "and there's a conflict on the user's username with a space" do
        before {
          FactoryGirl.create(:space, permalink: @attrs[:_full_name].parameterize)
          expect {
            click_button t('shibboleth.associate.new_account.create_new_account')
          }.not_to change{ User.count }
        }

        it { current_path.should eq(shibboleth_path) }
        it { has_failure_message "Username has already been taken" }
        it("doesn't create a ShibToken") { ShibToken.count.should be(0) }
        it("doesn't send emails") { UserMailer.should have_queue_size_of(0) }
      end

      context "and there's a conflict on the user's username with a room" do
        before {
          FactoryGirl.create(:bigbluebutton_room, param: @attrs[:_full_name].parameterize)
          expect {
            click_button t('shibboleth.associate.new_account.create_new_account')
          }.not_to change{ User.count }
        }

        it { current_path.should eq(shibboleth_path) }
        it { has_failure_message "Username has already been taken" }
        it("doesn't create a ShibToken") { ShibToken.count.should be(0) }
        it("doesn't send emails") { UserMailer.should have_queue_size_of(0) }
      end

      context "and there's a conflict in the user's email" do
        before {
          FactoryGirl.create(:user, email: @attrs[:email])
          expect {
            click_button t('shibboleth.associate.new_account.create_new_account')
          }.not_to change{ User.count }
        }

        it { current_path.should eq(shibboleth_path) }
        it { has_failure_message t('shibboleth.create_association.existent_account', email: @attrs[:email]) }
        it("doesn't create a ShibToken") { ShibToken.count.should be(0) }
        it("doesn't send emails") { UserMailer.should have_queue_size_of(0) }
      end
    end
  end

  context "a returning user" do
    let(:token) { FactoryGirl.create(:shib_token) }
    let(:user) { token.user }

    before {
      enable_shib
      setup_shib user.full_name, user.email, user.email
    }

    context "that has a valid account" do
      before {
        visit shibboleth_path
      }

      it { current_path.should eq(my_home_path) }
      it { should have_content user.full_name }
      it { should have_content user.email }
    end

    context "that has a disabled account" do
      before {
        user.disable
        visit shibboleth_path
      }

      it { current_path.should eq(root_path) }
      it { has_failure_message(I18n.t('shibboleth.login.local_account_disabled')) }
    end
  end

  context "redirects the user properly" do
    let!(:login_link) { t('devise.shared.links.login.federation') }
    before {
      enable_shib
      Site.current.update_attributes :shib_always_new_account => true
      setup_shib 'a full name', 'user@mconf.org', 'user@mconf.org'
    }

    context "when he was in the frontpage" do
      before {
        visit root_url
        click_link login_link
      }

      it { current_path.should eq(my_home_path) }
    end

    context "from a space's page" do
      before {
        @space = FactoryGirl.create(:space, :public => true)
        visit space_path(@space)

        # Access sign in path via link
        find("a[href='#{login_path}']").click

        click_link login_link
      }

      it { current_path.should eq(space_path(@space)) }
    end

    context "from the association page" do
      skip
      # the user was in the shibboleth association page "/secure/associate"
      # he user clicks to go to the login page
      # when the user clicks to sign in via shibboleth redirects the user to the association page
      # user clicks to create a new account
      # redirects the user to the space's page
    end
  end
end
