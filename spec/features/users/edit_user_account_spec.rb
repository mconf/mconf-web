require 'spec_helper'
require 'support/feature_helpers'

feature 'Editing a user account' do
  let(:admin) { FactoryGirl.create(:superuser) }
  let(:user) { FactoryGirl.create(:user) }

  scenario "a user accessing his own page should see current password field" do
    sign_in_with user.username, user.password

    visit edit_user_path(user)

    expect(page).to have_field("user_email", disabled: true, with: user.email)
    expect(page).to have_field("user_username", disabled: true, with: user.username)
    expect(page).to have_field("user_current_password")
  end

  scenario "an admin accessing his own page shouldn't see current password field" do
    sign_in_with admin.username, admin.password

    visit edit_user_path(admin)

    expect(page).to have_field("user_email", disabled: true, with: admin.email)
    expect(page).to have_field("user_username", disabled: true, with: admin.username)
    expect(page).to_not have_field("user_current_password")
  end

  scenario "an admin accessing a user page shouldn't see current password field" do
    sign_in_with admin.username, admin.password

    visit edit_user_path(user)

    expect(page).to have_field("user_email", disabled: true, with: user.email)
    expect(page).to have_field("user_username", disabled: true, with: user.username)
    expect(page).to_not have_field("user_current_password")
  end
end