require 'spec_helper'

describe 'Disabled shibboleth features' do
  subject { page }
  before(:all) {
    @attrs = FactoryGirl.attributes_for(:user, email: "user@mconf.org")
    @attrs[:profile_attributes] = FactoryGirl.attributes_for(:profile)
  }

  context "an account created via shibboleth" do
    before {
      enable_shib
      Site.current.update_attributes shib_always_new_account: true
      setup_shib @attrs[:profile_attributes][:full_name], @attrs[:email], @attrs[:email]
      visit shibboleth_path
    }

    context "don't show email confirmation page" do
      before { visit new_user_confirmation_path }

      it { current_path.should_not eq(new_user_confirmation_path) }
      it { has_success_message }
    end

    context "don't send forgot password email" do
      let(:user) { ShibToken.last.user }

      before {
        logout_user
        visit new_user_password_path

        fill_in 'user[email]', with: user.email
        find('input[type="submit"]').click
      }

      it { has_success_message }
      it { last_email.should be_nil }
    end

    context "shouldn't see password fields in edit screen" do
      before { visit edit_user_path(ShibToken.last.user) }

      it { page.should_not have_field("user_current_password") }
      it { page.should_not have_field("user_password") }
      it { page.should_not have_field("user_password_confirmation") }
    end

    context "shouldn't be able to login with the account password" do
      let(:user) { ShibToken.last.user }
      before {
        logout_user # user was logged in before

        user.update_attributes password: @attrs[:password] + '-1234578'
        sign_in_with(@attrs[:username], @attrs[:password] + '-1234578')
      }

      it { current_path.should eq(new_user_session_path) }
      it { has_failure_message t('devise.failure.not_found_in_database') }
    end
  end
end
