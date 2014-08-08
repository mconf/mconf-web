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
      sign_up_with('', '', '')
      click_link I18n.t('locales.en')
    }

    it { current_path.should eq(register_path) }
  end

  context 'with valid email and password' do
    before { sign_up_with 'Valid User Name', 'valid@example.com', 'password' }

    it { current_path.should eq(my_home_path) }
    it { page.find("#user-notifications").should have_link('', :href => new_user_confirmation_path) }
    it { has_success_message(I18n.t('devise.registrations.signed_up')) }
    it { page.should have_content('Logout') }
  end

  context 'with invalid email' do
    before { sign_up_with 'Valid User Name', 'invalid_email', 'password' }

    it { page.should have_content('Sign in') }
  end

  context 'with blank password' do
    before { sign_up_with 'Valid User Name', 'valid@example.com', '' }

    it { expect(page).to have_content('Sign in') }
  end

  context 'with blank name' do
    before { sign_up_with '', 'valid@example.com', 'password' }

    it { expect(page).to have_content('Sign in') }
  end

  def sanitize_name name
    name.downcase.gsub(/\s/, '-')
  end

  def sign_up_with(name, email, password)
    visit register_path
    fill_in 'user[email]', with: email
    fill_in 'user[password]', with: password
    fill_in 'user[password_confirmation]', with: password
    fill_in 'user[_full_name]', with: name
    fill_in 'user[username]', with: sanitize_name(name)
    click_button I18n.t('registrations.signup_form.register')
  end
end