# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'
require 'support/feature_helpers'

feature 'Visitor signs up' do

  scenario 'with valid email and password' do
    attrs = FactoryGirl.attributes_for(:user)
    attrs[:profile_attributes] = FactoryGirl.attributes_for(:profile)
    register_with(attrs)

    current_path.should eq(my_home_path)
    # TODO: #1087 include the confirmation link somewhere
    # page.find("#notification-flashs").should have_link('', href: new_user_confirmation_path)
    has_success_message(I18n.t('devise.registrations.signed_up'))
    page.should have_content('Logout')
  end

  scenario 'setting a locale different from Site default' do
    attrs = FactoryGirl.attributes_for(:user)
    attrs[:profile_attributes] = FactoryGirl.attributes_for(:profile)
    attrs[:different_locale] = session_locale_path(lang: 'pt-br')
    register_with(attrs)

    current_path.should eq(my_home_path)
    has_success_message(I18n.t('devise.registrations.signed_up'))
    page.should have_content('Sair')
  end

  scenario 'with invalid email' do
    attrs = FactoryGirl.attributes_for(:user, email: "invalid_email")
    attrs[:profile_attributes] = FactoryGirl.attributes_for(:profile)
    register_with(attrs)

    current_path.should eq(user_registration_path)

    has_field_with_error "user_email"
    page.should have_content('Sign in')
  end

  scenario 'with blank password' do
    attrs = FactoryGirl.attributes_for(:user, password: nil)
    attrs[:profile_attributes] = FactoryGirl.attributes_for(:profile)
    register_with(attrs)

    current_path.should eq(user_registration_path)
    has_field_with_error "user_password"
    expect(page).to have_content('Sign in')
  end

  scenario 'with blank name' do
    attrs = FactoryGirl.attributes_for(:user)
    attrs[:profile_attributes] = FactoryGirl.attributes_for(:profile, full_name: nil)
    register_with(attrs)

    current_path.should eq(user_registration_path)
    has_field_with_error "user_profile_full_name"
    expect(page).to have_content('Sign in')
  end

  scenario 'with the email of another user' do
    another_user = FactoryGirl.create(:user)
    attrs = FactoryGirl.attributes_for(:user, email: another_user.email)
    attrs[:profile_attributes] = FactoryGirl.attributes_for(:profile)
    register_with(attrs)

    current_path.should eq(user_registration_path)
    has_field_with_error "user_email"
  end

  scenario 'with the email of a disabled user' do
    disabled_user = FactoryGirl.create(:user, disabled: true)
    attrs = FactoryGirl.attributes_for(:user, email: disabled_user.email)
    attrs[:profile_attributes] = FactoryGirl.attributes_for(:profile)
    register_with(attrs)

    current_path.should eq(user_registration_path)
    has_field_with_error "user_email"
  end

  scenario 'with the username of another user' do
    another_user = FactoryGirl.create(:user, username: nil)
    attrs = FactoryGirl.attributes_for(:user, username: nil)
    attrs[:profile_attributes] = FactoryGirl.attributes_for(:profile, full_name: another_user.full_name)
    register_with(attrs)

    current_path.should eq(my_home_path)
    User.last.username.should eql(another_user.username + "-2")
  end

  scenario 'with the username of a disabled user' do
    disabled_user = FactoryGirl.create(:user, username: nil, disabled: true)
    attrs = FactoryGirl.attributes_for(:user, username: nil)
    attrs[:profile_attributes] = FactoryGirl.attributes_for(:profile, full_name: disabled_user.full_name)
    register_with(attrs)

    current_path.should eq(my_home_path)
    User.last.username.should eql(disabled_user.username + "-2")
  end

  scenario "with the username equal to some space's slug" do
    space = FactoryGirl.create(:space, slug: nil)
    attrs = FactoryGirl.attributes_for(:user, username: nil)
    attrs[:profile_attributes] = FactoryGirl.attributes_for(:profile, full_name: space.name)
    register_with(attrs)

    current_path.should eq(my_home_path)
    User.last.username.should eql(space.slug + "-2")
  end

  scenario "with the username equal to some disabled space's slug" do
    disabled_space = FactoryGirl.create(:space, disabled: true, slug: nil)
    attrs = FactoryGirl.attributes_for(:user, username: nil)
    attrs[:profile_attributes] = FactoryGirl.attributes_for(:profile, full_name: disabled_space.name)
    register_with(attrs)

    current_path.should eq(my_home_path)
    User.last.username.should eql(disabled_space.slug + "-2")
  end

  scenario "when the password confirmation doesn't match" do
    attrs = FactoryGirl.attributes_for(:user)
    attrs[:password_confirmation] = "#{attrs[:password]}-2"
    attrs[:profile_attributes] = FactoryGirl.attributes_for(:profile)
    register_with(attrs)

    current_path.should eq(user_registration_path)
    has_field_with_error "user_password_confirmation"
  end

  scenario "send invalid register form and try to change language after" do
    attrs = { email: "", password: "" }
    register_with(attrs)
    click_link "Português"

    current_path.should eq(register_path)
  end

  # TODO: Skipping because with_js is not working properly yet
  skip "generates a valid suggestion for the identifier", with_js: true do
    visit(register_path)
    fill_in "user[profile_attributes][full_name]", with: "Mr. Pink-man's #1 (5% of tries = WIN, \"haha\"): áéíôü"

    expected = "mr-pink-mans-1-5-of-tries-win-haha-aeiou"
    find_field('user[username]').value.should eql(expected)
  end

end
