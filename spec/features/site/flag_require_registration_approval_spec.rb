# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'
require 'support/feature_helpers'

include ActionView::Helpers::SanitizeHelper

feature 'Behaviour of the flag Site#require_registration_approval' do
  let(:attrs) {
    attrs = FactoryGirl.attributes_for(:user)
    attrs[:profile_attributes] = FactoryGirl.attributes_for(:profile)
    attrs
  }

  context "if admin approval is required" do
    before {
      Site.current.update_attributes(require_registration_approval: true)
    }

    context "registering in the website" do
      before {
        Site.current.update_attributes(events_enabled: false)

        with_resque do
          expect { register_with(attrs) }.to change{ User.count }.by(1)
        end
      }

      it { User.last.confirmed?.should be false }
      it { User.last.approved?.should be false }

      it "sends the correct confirmation email to the user", with_truncation: true do
        mail = email_by_subject t('devise.mailer.confirmation_instructions.subject')
        mail.should_not be_nil
        mail_content(mail).should_not match(/http.*users\/confirmation*/)
        mail_content(mail).should match(t('devise.mailer.confirmation_instructions.confirmation_pending'))
      end

      context "shows the pending approval page" do
        it { current_path.should eq(my_approval_pending_path) }
        it { page.should have_link('', :href => spaces_path) }
        it { page.should_not have_link('', :href => events_path) }
        it { page.should have_content('Sign in') }
        it { page.should have_content(I18n.t("my.approval_pending.title")) }
        it { page.should have_content(I18n.t("my.approval_pending.description")) }
      end

      # empty notification, the message is shown in the page
      it "shows no notification" do
        have_empty_notification
      end

      it "when the event module is enabled" do
        Site.current.update_attributes(events_enabled: true)
        current_path.should eq(my_approval_pending_path)
        page.should have_link('', :href => spaces_path)
      end
    end

    context "registering in the website after failing the first try" do
      before {
        with_resque do
          expect { register_with_error(attrs) }.to change{ User.count }.by(0)
        end
      }

      context "shows the user registration page" do
        it { current_path.should eq (user_registration_path) }
        it { page.should have_link('', :href => login_path) }
        it { page.should have_content('Register') }

        context "registering with correct data to succed the second try" do
          before {
            with_resque do
              expect { register_with(attrs, false) }.to change{ User.count }.by(1)
            end
          }

          it { User.last.confirmed?.should be false }
          it { User.last.approved?.should be false }

          it "sends the correct confirmation email to the user", with_truncation: true do
            mail = email_by_subject t('devise.mailer.confirmation_instructions.subject')
            mail_content(mail).should match(t('devise.mailer.confirmation_instructions.confirmation_pending'))
          end

          context "shows the pending approval page" do
            it { current_path.should eq(my_approval_pending_path) }
            it { page.should have_content(I18n.t("my.approval_pending.title")) }
            it { page.should have_content(I18n.t("my.approval_pending.description")) }
          end

          # empty notification, the message is shown in the page
          it "shows no notification" do
            have_empty_notification
          end

          it "when the event module is enabled" do
            Site.current.update_attributes(events_enabled: true)
            current_path.should eq(my_approval_pending_path)
          end
        end
      end
    end

    context "signing in via shibboleth for the first time, generating a new account" do
      before {
        enable_shib
        setup_shib attrs[:profile_attributes][:full_name], attrs[:email], attrs[:email]

        with_resque do
          expect {
            ActionDispatch::Request.any_instance.stub(:referer).and_return("http://mconf.org")
            visit shibboleth_path
            click_button t('shibboleth.associate.new_account.create_new_account')
          }.to change{ User.count }.by(1)
        end
      }

      it { User.last.confirmed?.should be true }
      it { User.last.approved?.should be false }

      it "doesn't a confirmation email to the user", with_truncation: true do
        mail = email_by_subject t('devise.mailer.confirmation_instructions.subject')
        mail.should be_nil
      end

      context "shows the pending approval page" do
        it { current_path.should eq(my_approval_pending_path) }
        it { page.should have_content('Sign in') }
        it { page.should have_content(I18n.t("my.approval_pending.title")) }
        it { page.should have_content(I18n.t("my.approval_pending.description")) }
      end

      it "shows no notification" do
        have_empty_notification
      end
    end

    it "signing in via LDAP for the first time, generating a new account"
  end

  context "if admin approval is required and the event module is enabled" do
    before {
      Site.current.update_attributes(require_registration_approval: true)
      Site.current.update_attributes(events_enabled: true)

      with_resque do
        expect { register_with(attrs) }.to change{ User.count }.by(1)
      end
    }

    context "shows the pending approval page" do
      it { current_path.should eq(my_approval_pending_path) }
      it { page.should have_content(I18n.t("my.approval_pending.title")) }
      it { page.should have_content(I18n.t("my.approval_pending.description")) }
      it { page.should have_link('', :href => events_path) }
    end
  end

  context "if admin approval is not required" do

    context "registering in the website" do
      before {
        Site.current.update_attributes(require_registration_approval: false)

        with_resque do
          expect { register_with(attrs) }.to change{ User.count }.by(1)
        end
      }

      it { User.last.confirmed?.should be false }
      it { User.last.approved?.should be true }

      it "send the correct confirmation email to the user", with_truncation: true do
        mail = email_by_subject t('devise.mailer.confirmation_instructions.subject')
        mail.should_not be_nil
        mail_content(mail).should match(/http.*users\/confirmation*/)
        mail_content(mail).should_not match(t('devise.mailer.confirmation_instructions.confirmation_pending'))
      end

      context "signs the user in" do
        it { current_path.should eq(my_home_path) }
        it { page.should have_content('Logout') }
      end

      it "shows the correct notification" do
        has_success_message t("devise.registrations.signed_up")
      end
    end

    context "signing in via shibboleth for the first time, generating a new account" do
      before {
        enable_shib
        setup_shib attrs[:profile_attributes][:full_name], attrs[:email], attrs[:email]

        with_resque do
          expect {
            visit shibboleth_path
            click_button t('shibboleth.associate.new_account.create_new_account')
          }.to change{ User.count }.by(1)
        end
      }

      it { User.last.confirmed?.should be true }
      it { User.last.approved?.should be true }

      it "doesn't send a confirmation email to the user", with_truncation: true do
        mail = email_by_subject t('devise.mailer.confirmation_instructions.subject')
        mail.should be_nil
      end

      context "shows the pending approval page" do
        it { current_path.should eq(my_home_path) }
      end

      it "shows the correct notification" do
        has_success_message strip_links(t("shibboleth.create_association.account_created"))
      end
    end

    it "signing in via LDAP for the first time, generating a new account"
  end

end
