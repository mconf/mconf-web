require 'spec_helper'
require 'rake'

describe 'Disabled ldap features' do
  subject { page }
  before(:all) {
    Mconf::Application.load_tasks
    @pid = fork do
      Rake::Task['ldap:server'].invoke
    end
  }

  after(:all) {
    Process.kill('SIGTERM', @pid)
  }

  context "an user account created via ldap" do
    before {
      # enable_ldap
      Site.current.update_attributes ldap_enabled: true

      sign_in_with('mconf', 'mconf')
    }

    context "shouldn't see password fields in edit screen" do
      before { visit edit_user_path(LdapToken.last.user) }

      it { page.should_not have_field("user_current_password") }
      it { page.should_not have_field("user_password") }
      it { page.should_not have_field("user_password_confirmation") }
    end
  end
end