require 'spec_helper'

feature 'Creating an user account as a global admin' do
  let(:admin) { FactoryGirl.create(:superuser) }

  context "when the site requires registration approval, the approved field should appear" do
    before {
      Site.current.update_attributes(require_registration_approval: true)
      sign_in_with admin.username, admin.password
      visit new_user_path
    }
    subject { page }

    it { should have_field("user_email") }
    it { should have_field("user__full_name") }
    it { should have_field("user_approved") }
    it { should have_field("user_can_record") }
    it { should have_field("user_username") }
    it { should have_field("user_password") }
    it { should have_field("user_password_confirmation") }
  end

  context "when the site doens't requires registration approval, the approved field should not appear" do
    before {
      sign_in_with admin.username, admin.password
      visit new_user_path
    }
    subject { page }

    it { should have_field("user_email") }
    it { should have_field("user__full_name") }
    it { should_not have_field("user_approved") }
    it { should have_field("user_can_record") }
    it { should have_field("user_username") }
    it { should have_field("user_password") }
    it { should have_field("user_password_confirmation") }
  end
end
