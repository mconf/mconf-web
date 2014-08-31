require 'spec_helper'
require 'support/feature_helpers'

feature "Confirmation email" do
  background do
    @attributes = FactoryGirl.attributes_for(:user).slice(:username, :_full_name, :email, :password)
  end

  # devise triggers callbacks to send emails that will not be triggered if using
  # transactions, so use truncation instead
  scenario "sends the correct confirmation link in the confirmation email", with_truncation: true do
    with_resque do
      expect {
        visit register_path
        fill_in "user[email]", with: @attributes[:email]
        fill_in "user[_full_name]", with: @attributes[:_full_name]
        fill_in "user[username]", with: @attributes[:username]
        fill_in "user[password]", with: @attributes[:password]
        fill_in "user[password_confirmation]", with: @attributes[:password]
        click_button "Register"
      }.to change{ User.count }.by(1)
    end

    User.last.confirmed?.should be false

    # check the confirmation email and click on the link to confirm the account
    last_email.should_not be_nil
    confirmation_link = last_email.body.encoded.match(/http.*users\/confirmation[^" ]*/)[0]
    last_email.body.encoded.should match(t('devise.mailer.confirmation_instructions.confirmation_ok'))
    visit confirmation_link

    User.last.confirmed?.should be true

    # TODO: check that the user is not signed in
  end

  scenario "send the correct message and no confirmation link if admin approval is required", with_truncation: true do
    Site.current.update_attributes(require_registration_approval: true)

    with_resque do
      expect {
        visit register_path
        fill_in "user[email]", with: @attributes[:email]
        fill_in "user[_full_name]", with: @attributes[:_full_name]
        fill_in "user[username]", with: @attributes[:username]
        fill_in "user[password]", with: @attributes[:password]
        fill_in "user[password_confirmation]", with: @attributes[:password]
        click_button "Register"
      }.to change{ User.count }.by(1)
    end

    User.last.confirmed?.should be false
    User.last.approved?.should be false

    # check the confirmation email
    last_email.should_not be_nil
    last_email.body.encoded.should_not match(/http.*users\/confirmation*/)
    last_email.body.encoded.should match(t('devise.mailer.confirmation_instructions.confirmation_pending'))

    # TODO: check that the user is not signed in
  end
end
