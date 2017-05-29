# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'
require 'support/feature_helpers'

feature "Confirmation email" do
  let(:attrs) {
    attrs = FactoryGirl.attributes_for(:user)
    attrs[:profile_attributes] = FactoryGirl.attributes_for(:profile)
    attrs
  }

  # devise triggers callbacks to send emails that will not be triggered if using
  # transactions, so use truncation instead
  it "sends the correct confirmation link in the confirmation email", with_truncation: true do
    with_resque do
      expect { register_with(attrs) }.to change{ User.count }.by(1)
    end

    User.last.should_not be_confirmed

    # check the confirmation email and click on the link to confirm the account
    last_email.should_not be_nil
    mail_content(last_email).should match(t('devise.mailer.confirmation_instructions.confirmation_ok'))
    confirmation_link = mail_content(last_email).match(/http[^ ]*users\/confirmation[^ ]*/)[0]
    confirmation_link.gsub!(/\s*/, '')
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
    mail_content(last_email).should match(t('devise.mailer.confirmation_instructions.confirmation_ok', locale: "pt-br"))
  end

  it "uses the default locale if the site has no locale set", with_truncation: true do
    I18n.default_locale = "pt-br"
    Site.current.update_attributes(locale: nil)
    with_resque do
      expect { register_with(attrs) }.to change{ User.count }.by(1)
    end
    last_email.should_not be_nil
    mail_content(last_email).should match(t('devise.mailer.confirmation_instructions.confirmation_ok', locale: "pt-br"))
  end

end
