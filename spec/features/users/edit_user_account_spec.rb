# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'
require 'support/feature_helpers'

feature 'Editing a user account', with_truncation: true do
  let!(:admin) { FactoryGirl.create(:superuser) }
  let!(:user) { FactoryGirl.create(:user) }

  scenario "a user updating his account should stay in the edit page" do
    sign_in_with user.username, user.password

    visit my_home_path
    find("a[href='#{ edit_user_path(user) }']").click
    find("[name='commit']", match: :first).click

    expect(current_path).to eq(edit_user_path(user))
  end

  scenario "an admin updating a user account should stay in the edit page" do
    sign_in_with admin.username, admin.password

    visit manage_users_path(q: user.username.first(3), admin: false)
    find("a[href='#{ edit_user_path(user) }']").click
    save_page
    find("[name='commit']", match: :first).click

    expect(current_path_with_query).to eq(edit_user_path(user))
  end

  # # bug1719 - Waiting for javascript tests
  # scenario "a user edit his account after acces a modal in his home page " do
  #   sign_in_with user.username, user.password
  #   visit my_home_path
  #   # try to invite users to his meeting
  #   find("a[href='#{ invitation_bigbluebutton_room_path(user) }']").click
  #   # closes/cancel the model
  #   find("a[data-dismiss='modal']").click
  #   # click on account
  #   find("a[href='#{ edit_user_path(user) }']").click
  #   # click on cancel
  #   find("//a[text()='#{ I18n.t('simple_form.buttons.cancel') }']").click

  #    expect(current_path).to eq(my_home_path)
  #   show_page
  # end

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
