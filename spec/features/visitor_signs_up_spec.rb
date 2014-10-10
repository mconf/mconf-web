require 'spec_helper'
require 'support/feature_helpers'

feature 'Visitor signs up' do

  context 'visit landing page' do
    before { visit root_path }

    it { page.should have_content(Site.current.name) }
    it { page.should have_content(I18n.t('frontpage.show.register.title')) }
    it { page.should have_content(I18n.t('frontpage.show.login.title')) }
  end

  context 'send invalid register form and try to change language after' do
    before {
      attrs = { email: "", _full_name: "", password: "" }
      register_with attrs
      click_link I18n.t('locales.en')
    }

    it { current_path.should eq(register_path) }
  end

  context 'with valid email and password' do
    before {
      attrs = { email: "valid@example.com", _full_name: "Valid User Name", password: "password" }
      register_with attrs
    }

    it { current_path.should eq(my_home_path) }
    it { page.find("#user-notifications").should have_link('', :href => new_user_confirmation_path) }
    it { has_success_message(I18n.t('devise.registrations.signed_up')) }
    it { page.should have_content('Logout') }
  end

  context 'with invalid email' do
    before {
      attrs = { email: "invalid_email", _full_name: "Valid User Name", password: "password" }
      register_with attrs
    }

    it { current_path.should eq(user_registration_path) }
    it { page.should have_content('Sign in') }
  end

  context 'with blank password' do
    before {
      attrs = { email: "valid@example.com", _full_name: "Valid User Name", password: "" }
      register_with attrs
    }

    it { current_path.should eq(user_registration_path) }
    it { expect(page).to have_content('Sign in') }
  end

  context 'with blank name' do
    before {
      attrs = { email: "valid@example.com", password: "password" }
      register_with attrs
    }

    it { current_path.should eq(user_registration_path) }
    it { expect(page).to have_content('Sign in') }
  end
end
