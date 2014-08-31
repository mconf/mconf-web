require 'spec_helper'
require 'support/feature_helpers'

feature 'Behaviour of the flag Site#require_registration_approval' do
  let(:attrs) { FactoryGirl.attributes_for(:user).slice(:username, :_full_name, :email, :password) }

  context "if admin approval is required" do
    before {
      Site.current.update_attributes(require_registration_approval: true)

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

    it "doesn't sign the user in"

    it "shows the correct notification" do
      has_success_message t("devise.registrations.signed_up_but_not_approved")
    end
  end

  context "if admin approval is not required" do
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

    it "signs the user in"

    it "shows the correct notification" do
      has_success_message t("devise.registrations.signed_up")
    end
  end

end
