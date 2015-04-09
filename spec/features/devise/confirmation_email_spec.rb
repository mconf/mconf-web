require 'spec_helper'
require 'support/feature_helpers'

feature "Confirmation email" do
  let(:attrs) { FactoryGirl.attributes_for(:user) }

  # devise triggers callbacks to send emails that will not be triggered if using
  # transactions, so use truncation instead
  it "sends the correct confirmation link in the confirmation email", with_truncation: true do
    with_resque do
      expect { register_with(attrs) }.to change{ User.count }.by(1)
    end

    User.last.confirmed?.should be false

    # check the confirmation email and click on the link to confirm the account
    last_email.should_not be_nil
    confirmation_link = last_email.body.encoded.match(/http.*users\/confirmation[^" (]*/)[0]
    last_email.body.encoded.should match(t('devise.mailer.confirmation_instructions.confirmation_ok'))
    visit confirmation_link

    User.last.confirmed?.should be true

    # TODO: check that the user is not signed in
  end

  it "uses the site's locale", with_truncation: true do
    Site.current.update_attributes(locale: "pt-br")
    with_resque do
      expect { register_with(attrs) }.to change{ User.count }.by(1)
    end
    last_email.should_not be_nil
    last_email.html_part.body.encoded.should match(t('devise.mailer.confirmation_instructions.confirmation_ok', locale: "pt-br"))
  end

  it "uses the default locale if the site has no locale set", with_truncation: true do
    I18n.default_locale = "pt-br"
    Site.current.update_attributes(locale: nil)
    with_resque do
      expect { register_with(attrs) }.to change{ User.count }.by(1)
    end
    last_email.should_not be_nil
    last_email.html_part.body.encoded.should match(t('devise.mailer.confirmation_instructions.confirmation_ok', locale: "pt-br"))
  end

end
