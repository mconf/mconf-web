# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'
require 'support/feature_helpers'

feature "Confirmation instructions" do

  context "a signed in user requesting confirmation instructions" do
    scenario "and the user is not confirmed yet" do
      user = FactoryGirl.create(:unconfirmed_user)
      sign_in_with user.username, user.password

      with_resque do
        expect {
          visit new_user_confirmation_path
          expect(page).to have_field("user_email", with: user.email)
          expect(page).to have_css("#user_email[readonly]")
          click_button I18n.t('user.request_confirmation')
        }.to send_email(1)
      end

      # the email must have at least some text we expect and the confirmation link
      last_email.should_not be_nil
      last_email.subject.should eql(I18n.t('devise.mailer.confirmation_instructions.subject'))
      mail_content(last_email).should match(/http.*users\/confirmation[^" ]*/)
      mail_content(last_email).should match(t('devise.mailer.confirmation_instructions.confirmation_ok'))
      mail_content(last_email).should match(t('devise.mailer.confirmation_instructions.welcome', email: user.email))

      current_path.should eq(my_home_path)
      has_success_message
    end

    scenario "and the user is already confirmed" do
      user = FactoryGirl.create(:user)
      sign_in_with user.username, user.password

      with_resque do
        expect {
          visit new_user_confirmation_path
        }.not_to send_email
      end

      current_path.should eq(my_home_path)
      has_success_message I18n.t('confirmations.check_already_confirmed.already_confirmed')
    end
  end

  context "an anonymous user requesting confirmation instructions" do
    scenario "and the user is not confirmed yet" do
      user = FactoryGirl.create(:unconfirmed_user)

      with_resque do
        expect {
          visit new_user_confirmation_path
          fill_in 'user[email]', with: user.email
          click_button I18n.t('user.request_confirmation')
        }.to send_email(1)
      end

      # the email must have at least some text we expect and the confirmation link
      last_email.should_not be_nil
      last_email.subject.should eql(I18n.t('devise.mailer.confirmation_instructions.subject'))
      mail_content(last_email).should match(/http.*users\/confirmation[^" ]*/)
      mail_content(last_email).should match(t('devise.mailer.confirmation_instructions.confirmation_ok'))
      mail_content(last_email).should match(t('devise.mailer.confirmation_instructions.welcome', email: user.email))

      current_path.should eq(new_user_session_path)
      has_success_message
    end

    scenario "and the user is already confirmed" do
      user = FactoryGirl.create(:user)

      with_resque do
        expect {
          visit new_user_confirmation_path
          fill_in 'user[email]', with: user.email
          click_button I18n.t('user.request_confirmation')
        }.not_to send_email
      end

      current_path.should eq(new_user_session_path)
      has_success_message
    end

    scenario "and the user doesn't exist" do
      with_resque do
        expect {
          visit new_user_confirmation_path
          fill_in 'user[email]', with: "invalid@invalid.org"
          click_button I18n.t('user.request_confirmation')
        }.not_to send_email
      end

      current_path.should eq(new_user_session_path)
      has_success_message
    end
  end
end
