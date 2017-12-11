# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

def register_user(params)
  fill_in 'user[email]', with: params[:email]
  fill_in 'user[profile_attributes][full_name]', with: params[:profile_attributes][:full_name]
  fill_in 'user[password]', with: params[:password]
  fill_in 'user[password_confirmation]', with: params[:password]

  click_button I18n.t("registrations.signup_form.register")
end

feature 'Creating a user account' do
  let(:admin) { FactoryGirl.create(:superuser) }

  skip 'an admin registering a user', with_js: true do
    sign_in_with admin.username, admin.password

    # TODO: open via xhr, it's a modal
    visit new_user_path

    expect(page).to have_field("user_email")
    expect(page).to have_field("user_profile_attributes_full_name")
    expect(page).to have_field("user_can_record")
    expect(page).to have_field("user_username")
    expect(page).to have_field("user_password")
    expect(page).to have_field("user_password_confirmation")
  end

  context 'a normal user register a new account' do
    let(:params) {
      attrs = FactoryGirl.attributes_for(:user)
      attrs[:profile_attributes] = FactoryGirl.attributes_for(:profile)
      attrs
    }

    context 'with captcha disabled' do
      before {
        Site.current.update_attributes captcha_enabled: false
        visit new_user_registration_path
      }

      it { expect(page).not_to have_selector('.captcha') }

      context 'sending the form' do
        before { register_user(params) }

        it { current_path.should eq(my_home_path) }
        it { has_success_message }
      end
    end

    context 'with captcha enabled' do
      before {
        Site.current.update_attributes captcha_enabled: true, recaptcha_public_key: 'abc'
        visit new_user_registration_path
      }

      it { expect(page).to have_selector('.captcha') }

      context 'sending the form with wrong captcha' do
        before {
          RegistrationsController.any_instance.should_receive(:verify_captcha).and_return(false)
          register_user(params)
        }

        it { current_path.should eq(user_registration_path) }
        it { has_failure_message t('recaptcha.errors.verification_failed') }
        it { page.should have_css("input[name='user[email]'][value='#{params[:email]}']") }
        it { page.should have_css("input[name='user[profile_attributes][full_name]'][value='#{params[:profile_attributes][:full_name]}']") }
        it { find_field('user[password]').value.should be_nil }
        it { find_field('user[password_confirmation]').value.should be_nil }
      end

      context 'sending the form with right captcha' do
        before {
          RegistrationsController.any_instance.should_receive(:verify_captcha).and_return(true)
          register_user(params)
        }

        it { current_path.should eq(my_home_path) }
        it { has_success_message }
      end
    end

  end
end
