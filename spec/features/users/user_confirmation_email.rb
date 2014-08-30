require 'spec_helper'
require 'support/feature_helpers'

feature "Confirmation email" do
  background do
    @attributes = FactoryGirl.attributes_for(:user).slice(:username, :_full_name, :email, :password)
  end
  scenario "register the user and check if the confirmation token is correct" do
    skip
    visit register_path

    fill_in "user[email]", with: @attributes[:email]
    fill_in "user[_full_name]", with: @attributes[:_full_name]
    fill_in "user[username]", with: @attributes[:username]
    fill_in "user[password]", with: @attributes[:password]
    fill_in "user[password_confirmation]", with: @attributes[:password]

    click_button "Register"

    #show_page
    token = extract_confirmation_token last_email
    user = User.find_by_username(@attributes[:username])
    #TODO: verify if the token sent in the email corresponds to that one in the database
  end

  scenario "verify if the email changes according to require_admin_approval" do
    skip
    visit register_path

    fill_in "user[email]", with: @attributes[:email]
    fill_in "user[_full_name]", with: @attributes[:_full_name]
    fill_in "user[username]", with: @attributes[:username]
    fill_in "user[password]", with: @attributes[:password]
    fill_in "user[password_confirmation]", with: @attributes[:password]

    click_button "Register"

    #show_page
    token = extract_confirmation_token last_email
    user = User.find_by_username(@attributes[:username])
    #TODO: verify if the email content changes according to the flag require_admin_approval
  end
end

def last_email
  ActionMailer::Base.deliveries.last
end

def extract_confirmation_token(email)
  email && email.body && email.body.match(/confirmation_token=(.+)">/x)[1]
end