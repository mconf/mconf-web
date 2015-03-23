require 'spec_helper'

feature 'Creating a user account' do
  let(:admin) { FactoryGirl.create(:superuser) }

  scenario 'an admin registering a user' do
    sign_in_with admin.username, admin.password

    visit new_user_path

    expect(page).to have_field("user_email")
    expect(page).to have_field("user__full_name")
    expect(page).to have_field("user_can_record")
    expect(page).to have_field("user_username")
    expect(page).to have_field("user_password")
    expect(page).to have_field("user_password_confirmation")
  end
end
