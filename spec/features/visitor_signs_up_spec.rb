# -*- coding: utf-8 -*-
require 'spec_helper'
require 'support/feature_helpers'

feature 'Visitor signs up' do

  scenario 'with valid email and password' do
    attrs = FactoryGirl.attributes_for(:user)
    register_with attrs

    current_path.should eq(my_home_path)
    page.find("#user-notifications").should have_link('', href: new_user_confirmation_path)
    has_success_message(I18n.t('devise.registrations.signed_up'))
    page.should have_content('Logout')
  end

  scenario 'with invalid email' do
    attrs = FactoryGirl.attributes_for(:user, email: "invalid_email")
    register_with attrs

    current_path.should eq(user_registration_path)
    has_field_with_error "user_email"
    page.should have_content('Sign in')
  end

  scenario 'with blank password' do
    attrs = FactoryGirl.attributes_for(:user, password: nil)
    register_with attrs

    current_path.should eq(user_registration_path)
    has_field_with_error "user_password"
    expect(page).to have_content('Sign in')
  end

  scenario 'with blank name' do
    attrs = FactoryGirl.attributes_for(:user, _full_name: nil)
    register_with attrs

    current_path.should eq(user_registration_path)
    has_field_with_error "user__full_name"
    expect(page).to have_content('Sign in')
  end

  scenario 'with the email of another user' do
    another_user = FactoryGirl.create(:user)
    attrs = FactoryGirl.attributes_for(:user, email: another_user.email)
    register_with attrs

    current_path.should eq(user_registration_path)
    has_field_with_error "user_email"
  end

  scenario 'with the email of a disabled user' do
    disabled_user = FactoryGirl.create(:user, disabled: true)
    attrs = FactoryGirl.attributes_for(:user, email: disabled_user.email)
    register_with attrs

    current_path.should eq(user_registration_path)
    has_field_with_error "user_email"
  end

  scenario 'with the username of another user' do
    another_user = FactoryGirl.create(:user)
    attrs = FactoryGirl.attributes_for(:user, username: another_user.username)
    register_with attrs

    current_path.should eq(user_registration_path)
    has_field_with_error "user_username"
  end

  scenario 'with the username of a disabled user' do
    disabled_user = FactoryGirl.create(:user)
    attrs = FactoryGirl.attributes_for(:user, username: disabled_user.username)
    register_with attrs

    current_path.should eq(user_registration_path)
    has_field_with_error "user_username"
  end

  scenario "with the username equal to some space's permalink" do
    space = FactoryGirl.create(:space)
    attrs = FactoryGirl.attributes_for(:user, username: space.permalink)
    register_with attrs

    current_path.should eq(user_registration_path)
    has_field_with_error "user_username"
  end

  scenario "with the username equal to some disabled space's permalink" do
    disabled_space = FactoryGirl.create(:space, disabled: true)
    attrs = FactoryGirl.attributes_for(:user, username: disabled_space.permalink)
    register_with attrs

    current_path.should eq(user_registration_path)
    has_field_with_error "user_username"
  end

  scenario "when the password confirmation doesn't match" do
    attrs = FactoryGirl.attributes_for(:user)
    attrs[:password_confirmation] = "#{attrs[:password]}-2"
    register_with attrs

    current_path.should eq(user_registration_path)
    has_field_with_error "user_password_confirmation"
  end

  scenario "send invalid register form and try to change language after" do
    attrs = { email: "", _full_name: "", password: "" }
    register_with attrs
    click_link I18n.t('locales.pt-br')

    current_path.should eq(register_path)
  end

  # TODO: Skipping because with_js is not working properly yet
  skip "generates a valid suggestion for the identifier", with_js: true do
    visit register_path
    fill_in "user[_full_name]", with: "Mr. Pink-man's #1 (5% of tries = WIN, \"haha\"): áéíôü"

    expected = "mr-pink-mans-1-5-of-tries-win-haha-aeiou"
    find_field('user[username]').value.should eql(expected)
  end

end
