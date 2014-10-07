require 'spec_helper'
require 'support/feature_helpers'

feature 'Behaviour of the flag Site#require_registration_approval' do
  let(:attrs) { FactoryGirl.attributes_for(:user).slice(:username, :_full_name, :email, :password) }

  context "if admin approval is required" do

    context "registering in the website" do
      before {
        Site.current.update_attributes(require_registration_approval: true)
        Site.current.update_attributes(events_enabled: false)

        with_resque do
          expect { register_with(attrs) }.to change{ User.count }.by(1)
        end
      }

      it { User.last.confirmed?.should be false }
      it { User.last.approved?.should be false }

      it "send the correct email", with_truncation: true do
        last_email.should_not be_nil
        last_email.body.encoded.should_not match(/http.*users\/confirmation*/)
        last_email.body.encoded.should match(t('devise.mailer.confirmation_instructions.confirmation_pending'))
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

    it "signing in via shibboleth for the first time, generating a new account"
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

      it "send the correct email", with_truncation: true do
        last_email.should_not be_nil
        last_email.body.encoded.should match(/http.*users\/confirmation*/)
        last_email.body.encoded.should_not match(t('devise.mailer.confirmation_instructions.confirmation_pending'))
      end

      context "signs the user in" do
        it { current_path.should eq(my_home_path) }
        it { page.should have_content('Logout') }
      end

      it "shows the correct notification" do
        has_success_message t("devise.registrations.signed_up")
      end
    end

    it "signing in via shibboleth for the first time, generating a new account"
    it "signing in via LDAP for the first time, generating a new account"
  end

end
