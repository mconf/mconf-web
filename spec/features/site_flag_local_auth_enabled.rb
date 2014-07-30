require 'spec_helper'
require 'support/feature_helpers'

feature 'Behaviour of the flag Site#local_auth_enabled' do
  let(:user) { FactoryGirl.create(:user) }
  let(:admin) { FactoryGirl.create(:superuser) }

  context "when the flag is set" do
    before { Site.current.update_attributes(local_auth_enabled: true) }

    scenario 'allows local authentication for normal users' do
      visit login_path
      fill_in 'user[login]', with: user.username
      fill_in 'user[password]', with: user.password
      click_button 'Login'

      expect(current_path).to eq(my_home_path)
    end

    scenario "shows the 'recover password' link in the login page"
    scenario "shows the 'sign in' link in the login page"
    scenario "shows the 'login' link in the navbar even if LDAP is disabled"
    scenario "shows the password inputs in users/edit even for normal users"

  end

  context "when the flag is not set" do
    before { Site.current.update_attributes(local_auth_enabled: false) }

    scenario 'blocks sign in for normal users' do
      visit login_path
      fill_in 'user[login]', with: user.username
      fill_in 'user[password]', with: user.password
      click_button 'Login'

      expect(current_path).to eq(new_user_session_path)
    end

    scenario 'allows the sign in of admins' do
      visit login_path
      fill_in 'user[login]', with: admin.username
      fill_in 'user[password]', with: admin.password
      click_button 'Login'

      expect(current_path).to eq(my_home_path)
    end

    scenario "still shows the 'recover password' link in the login page"
    scenario "still shows the 'sign in' link in the login page"
    scenario "hides the 'login' link from the navbar if LDAP is also disabled"
    scenario "hides the password inputs from users/edit"
    scenario "shows the password inputs in users/edit if the user is an admin"

  end
end
