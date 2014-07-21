require 'spec_helper'

feature 'User signs in' do
  scenario "for the first time when the flag `shib_always_new_account` is set" do
    pending
    # redirects the user to his home page, skipping the association page
    # creates a new account for the user
    # creates a new ShibToken for the user
  end

  scenario "for the first time when the flag `shib_always_new_account` is not set and the user wants a new account" do
    pending
    # shows the association page
    # the user selects to create a new account
    # redirects the user to his home page
    # creates a new account for the user
    # creates a new ShibToken for the user
  end

  scenario "for the first time when the flag `shib_always_new_account` is not set and the user already has another account" do
    pending
    # shows the association page
    # the user enters the credentials to his other account
    # redirects the user to his home page
    # creates a new ShibToken for the user, associating his previous account with his shibboleth account
  end

  scenario "the user enters the wrong credentials in the association page" do
    pending
    # renders the association page showing a notification error
  end
end
