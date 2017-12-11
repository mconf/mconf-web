# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe SubscriptionMailer do
  before {
    Mconf::Iugu.stub(:create_plan).and_return(Forgery::CreditCard.number)
    Mconf::Iugu.stub(:create_subscription).and_return(Forgery::CreditCard.number)
    Mconf::Iugu.stub(:create_customer).and_return(Forgery::CreditCard.number)
    Mconf::Iugu.stub(:update_customer).and_return(true)
  }

  let(:user) { FactoryGirl.create(:user) }
  let!(:subscription) { FactoryGirl.create(:subscription, user: user) }

  describe '.subscription_created_notification_email' do
    let(:mail) { SubscriptionMailer.subscription_created_notification_email(user.id, subscription.id) }
    let(:url) { "www.test.com" }

    context "attendee_key.present" do
      let(:room) { FactoryGirl.create(:bigbluebutton_room, owner: user, attendee_key: "123") }

      it ("renders the participant password") {
        content = I18n.t('subscription_mailer.subscription_created_notification_email.message.participants')
        mail_content(mail).should match(content)
      }
    end

    it("sets 'to'") { mail.to.should eql([user.email]) }
    it("sets 'subject'") do
      text = I18n.t('subscription_mailer.subscription_created_notification_email.subject', :name => user.name)
      mail.subject.should eql(text)
    end
    it("sets 'from'") { mail.from.should eql([Site.current.smtp_sender]) }
    it("sets 'headers'") { mail.headers.should eql({}) }
    it("renders the link to see the web conference room of the user") {
      allow_any_instance_of( Rails.application.routes.url_helpers ).to receive(:join_webconf_url).and_return(url)
      content = I18n.t('subscription_mailer.subscription_created_notification_email.message.link', :url => url).html_safe
      mail_content(mail).should match(content)
    }
  end

  describe '.subscription_destroyed_notification_email' do
    let(:mail) { SubscriptionMailer.subscription_destroyed_notification_email(user.id) }
    let(:url) { "www.contact.com" }

    it("sets 'to'") { mail.to.should eql([user.email]) }
    it("sets 'subject'") do
      text = I18n.t('subscription_mailer.subscription_destroyed_notification_email.subject', :name => user.name)
      mail.subject.should eql(text)
    end
    it("sets 'from'") { mail.from.should eql([Site.current.smtp_sender]) }
    it("sets 'headers'") { mail.headers.should eql({}) }
    it("renders contact email") do
      content = I18n.t('subscription_mailer.subscription_destroyed_notification_email.message.contact', :contact_email => Site.current.smtp_receiver).html_safe
      mail_content(mail).should match(content)
    end
  end
end
