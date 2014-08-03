require 'spec_helper'

feature 'User signs in via shibboleth' do
  scenario "for the first time when the flag `shib_always_new_account` is set" do
    skip
    # redirects the user to his home page, skipping the association page
    # creates a new account for the user
    # creates a new ShibToken for the user
  end

  scenario "for the first time when the flag `shib_always_new_account` is not set and the user wants a new account" do
    skip
    # shows the association page
    # the user selects to create a new account
    # redirects the user to his home page
    # creates a new account for the user
    # creates a new ShibToken for the user
  end

  scenario "for the first time when the flag `shib_always_new_account` is not set and the user already has another account" do
    skip
    # shows the association page
    # the user enters the credentials to his other account
    # redirects the user to his home page
    # creates a new ShibToken for the user, associating his previous account with his shibboleth account
  end

  scenario "the user enters the wrong credentials in the association page" do
    skip
    # renders the association page showing a notification error
  end

  feature "redirects the user properly" do
    scenario "when he was in the frontpage" do
      skip
      # he user clicks to go to the login page
      # when the user clicks to sign in via shibboleth redirects the user to the association page
      # user clicks to create a new account
      # redirects the user to his home page
    end

    scenario "from a space's page" do
      skip
      # he user clicks to go to the login page
      # when the user clicks to sign in via shibboleth redirects the user to the association page
      # user clicks to create a new account
      # redirects the user to the space's page
    end

    scenario "from the association page" do
      skip
      # the user was in the shibboleth association page "/secure/associate"
      # he user clicks to go to the login page
      # when the user clicks to sign in via shibboleth redirects the user to the association page
      # user clicks to create a new account
      # redirects the user to the space's page
    end
  end
end
