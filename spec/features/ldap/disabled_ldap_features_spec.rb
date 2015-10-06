require 'spec_helper'

describe 'Disabled ldap features' do
  subject { page }
  before(:all) { Mconf::LdapServerRunner.start }
  after(:all) { Mconf::LdapServerRunner.stop }

  context "an user account created via ldap" do
    before {
      Site.current.update_attributes ldap_enabled: true, ldap_host: '127.0.0.1'

      sign_in_with('mconf', 'mconf')
    }

    context "don't show email confirmation page" do
      before { visit new_user_confirmation_path }

      it { current_path.should_not eq(new_user_confirmation_path) }
      it { has_success_message }
    end

    context "don't send forgot password email" do
      let(:user) { LdapToken.last.user }

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
      before { visit edit_user_path(LdapToken.last.user) }

      it { page.should_not have_field("user_current_password") }
      it { page.should_not have_field("user_password") }
      it { page.should_not have_field("user_password_confirmation") }
    end

    context "shouldn't be able to login with the account password" do
      let(:user) { LdapToken.last.user }
      before {
        logout_user # user was logged in before to create an ldap token

        user.update_attributes password: '1234578'
        sign_in_with('mconf', '12345678')
      }

      it { current_path.should eq(new_user_session_path) }
      it { has_failure_message t('devise.failure.not_found_in_database') }
    end
  end
end