require 'spec_helper'

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
      end

      context "the user enters the wrong credentials in the association page" do
        before { click_button t('shibboleth.associate.existent_account.link_to_this_account') }

        it { has_failure_message }
        it { current_path.should eq(shibboleth_path) }
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
