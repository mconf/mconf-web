require 'spec_helper'
require 'support/feature_helpers'

include ActionView::Helpers::SanitizeHelper

feature 'Behaviour of the flag Site#require_registration_approval' do
  let(:attrs) { FactoryGirl.attributes_for(:user) }

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
        mail.body.encoded.should_not match(/http.*users\/confirmation*/)
        mail.body.encoded.should match(t('devise.mailer.confirmation_instructions.confirmation_pending'))
      end

      context "shows the pending approval page" do
        it { current_path.should eq(my_approval_pending_path) }
        it { page.should have_link('', :href => spaces_path) }
        it { page.should_not have_link('', :href => mweb_events.events_path) }
        it { page.should have_content('Sign in') }
        it { page.should have_content('Pending approval') }
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

    context "signing in via shibboleth for the first time, generating a new account" do
      before {
        enable_shib
        setup_shib attrs[:_full_name], attrs[:email], attrs[:email]

        with_resque do
          expect {
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
        it { page.should have_content('Pending approval') }
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
      it { page.should have_content('Pending approval') }
      it { page.should have_content(I18n.t("my.approval_pending.description")) }
      it { page.should have_link('', :href => mweb_events.events_path) }
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
        mail.body.encoded.should match(/http.*users\/confirmation*/)
        mail.body.encoded.should_not match(t('devise.mailer.confirmation_instructions.confirmation_pending'))
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
        setup_shib attrs[:_full_name], attrs[:email], attrs[:email]

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
